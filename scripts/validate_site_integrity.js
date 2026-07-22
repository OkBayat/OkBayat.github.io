#!/usr/bin/env node

const fs = require("fs")
const path = require("path")

const ROOT = path.resolve(__dirname, "..")
const SITE_HOSTS = new Set(["okbayat.com", "www.okbayat.com"])
const PAGE_EXTENSIONS = new Set([".md", ".html"])
const ARTICLE_ROOTS = new Set([
  "essays",
  "research-notes",
  "reading-notes",
  "translations",
])
const errors = new Set()

function walk(directory, ignoredDirectories = new Set()) {
  if (!fs.existsSync(directory)) return []

  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    if (ignoredDirectories.has(entry.name)) return []

    const entryPath = path.join(directory, entry.name)
    return entry.isDirectory()
      ? walk(entryPath, ignoredDirectories)
      : [entryPath]
  })
}

function relative(filePath) {
  return path.relative(ROOT, filePath).split(path.sep).join("/")
}

function parseScalar(rawValue) {
  const value = rawValue.trim()
  if (value === "") return ""

  if (
    (value.startsWith('"') && value.endsWith('"')) ||
    (value.startsWith("'") && value.endsWith("'"))
  ) {
    return value.slice(1, -1)
  }

  return value
}

function parseFrontMatter(filePath) {
  const source = fs.readFileSync(filePath, "utf8")
  const match = source.match(
    /^(?:\uFEFF)?---\s*\r?\n([\s\S]*?)\r?\n---(?:\s*\r?\n|$)/
  )

  if (!match) {
    errors.add(`${relative(filePath)}: missing YAML front matter`)
    return { body: source, data: {} }
  }

  const data = {}
  for (const line of match[1].split(/\r?\n/)) {
    const field = line.match(/^([A-Za-z_][A-Za-z0-9_-]*):(?:\s*(.*))?$/)
    if (field) data[field[1]] = parseScalar(field[2] || "")
  }

  return { body: source.slice(match[0].length), data }
}

function normalizeRoute(value) {
  let route = value.split(/[?#]/, 1)[0]
  try {
    route = decodeURI(route)
  } catch {
    return null
  }

  route = route.replace(/\\/g, "/").replace(/\/{2,}/g, "/")
  if (!route.startsWith("/")) route = `/${route}`
  if (route.length > 1) route = route.replace(/\/+$/, "")
  return route
}

function addRoute(routes, route) {
  const normalized = normalizeRoute(route)
  if (!normalized) return

  routes.add(normalized)
  if (normalized.endsWith("/index.html")) {
    routes.add(normalized.slice(0, -11) || "/")
  } else if (normalized.endsWith(".html")) {
    routes.add(normalized.slice(0, -5) || "/")
  }
}

function sourceRoute(filePath, frontMatter) {
  if (frontMatter.permalink) return normalizeRoute(frontMatter.permalink)

  let route = `/${relative(filePath).replace(/\.(md|html)$/, "")}`
  if (route.endsWith("/index")) route = route.slice(0, -6) || "/"
  return normalizeRoute(route)
}

function isArticle(filePath) {
  const parts = relative(filePath).split("/")
  return (
    parts[0] === "docs" &&
    parts[1] === "thinking" &&
    ARTICLE_ROOTS.has(parts[2]) &&
    path.basename(filePath) !== "index.md"
  )
}

function validateLanguageMetadata(page) {
  const { data, filePath } = page
  const file = relative(filePath)
  const allowedLanguages = new Set(["en", "fa"])
  const allowedDirections = new Set(["ltr", "rtl"])
  const allowedLocales = new Set(["en_US", "fa_IR"])

  if (data.lang && !allowedLanguages.has(data.lang)) {
    errors.add(`${file}: lang must be en or fa, found ${data.lang}`)
  }
  if (data.direction && !allowedDirections.has(data.direction)) {
    errors.add(`${file}: direction must be ltr or rtl, found ${data.direction}`)
  }
  if (data.locale && !allowedLocales.has(data.locale)) {
    errors.add(`${file}: locale must be en_US or fa_IR, found ${data.locale}`)
  }

  if (data.lang === "fa") {
    if (data.direction && data.direction !== "rtl") {
      errors.add(`${file}: Persian pages must use direction: rtl`)
    }
    if (data.locale && data.locale !== "fa_IR") {
      errors.add(`${file}: Persian pages must use locale: fa_IR`)
    }
  }

  if (data.lang === "en") {
    if (data.direction && data.direction !== "ltr") {
      errors.add(`${file}: English pages must use direction: ltr`)
    }
    if (data.locale && data.locale !== "en_US") {
      errors.add(`${file}: English pages must use locale: en_US`)
    }
  }

  const expectedLanguage = file.endsWith("-fa.md")
    ? "fa"
    : file.endsWith("-en.md")
      ? "en"
      : null
  if (expectedLanguage && data.lang !== expectedLanguage) {
    errors.add(
      `${file}: filename requires lang: ${expectedLanguage}, found ${data.lang || "none"}`
    )
  }

  if (isArticle(filePath)) {
    const expected =
      data.lang === "fa"
        ? { direction: "rtl", locale: "fa_IR" }
        : { direction: "ltr", locale: "en_US" }

    if (!allowedLanguages.has(data.lang)) {
      errors.add(`${file}: articles must declare lang: en or lang: fa`)
      return
    }
    if (data.direction !== expected.direction) {
      errors.add(
        `${file}: lang: ${data.lang} requires direction: ${expected.direction}`
      )
    }
    if (data.locale !== expected.locale) {
      errors.add(
        `${file}: lang: ${data.lang} requires locale: ${expected.locale}`
      )
    }
  }
}

function extractLinks(content) {
  const links = []
  const patterns = [
    /\b(?:href|src)=["']([^"']+)["']/gi,
    /!?\[[^\]]*\]\(([^)]+)\)/g,
    /^\s*\[[^\]]+\]:\s*(\S+)/gm,
  ]

  for (const pattern of patterns) {
    for (const match of content.matchAll(pattern)) links.push(match[1])
  }

  return links
}

function cleanLinkTarget(rawTarget) {
  let target = rawTarget.trim().replace(/&amp;/g, "&")
  if (target.startsWith("<")) {
    const end = target.indexOf(">")
    if (end !== -1) return target.slice(1, end)
  }

  return target.split(/\s+["'(]/, 1)[0]
}

function resolveInternalTarget(rawTarget, pageRoute) {
  const target = cleanLinkTarget(rawTarget)
  if (
    target === "" ||
    target.startsWith("#") ||
    target.includes("{{") ||
    /^(?:mailto|tel|javascript|data):/i.test(target)
  ) {
    return null
  }

  if (target.startsWith("//")) return null

  if (/^https?:\/\//i.test(target)) {
    let url
    try {
      url = new URL(target)
    } catch {
      return null
    }
    if (!SITE_HOSTS.has(url.hostname.toLowerCase())) return null
    return normalizeRoute(url.pathname)
  }

  if (target.startsWith("/")) return normalizeRoute(target)
  if (!pageRoute) return null
  if (
    !target.startsWith("./") &&
    !target.startsWith("../") &&
    !target.includes("/") &&
    !/\.(?:html?|md|pdf|png|jpe?g|gif|svg|webp|mp3|mp4)(?:[?#]|$)/i.test(target)
  ) {
    return null
  }

  const basePath = pageRoute.endsWith(".html")
    ? pageRoute
    : `${pageRoute === "/" ? "" : pageRoute}/`
  try {
    return normalizeRoute(
      new URL(target, `https://www.okbayat.com${basePath}`).pathname
    )
  } catch {
    return null
  }
}

function validateLinks(content, sourceLabel, pageRoute, routes) {
  for (const rawTarget of extractLinks(content)) {
    const target = resolveInternalTarget(rawTarget, pageRoute)
    if (target && !routes.has(target)) {
      errors.add(
        `${sourceLabel}: broken internal link ${rawTarget} -> ${target}`
      )
    }
  }
}

function sourcePages() {
  const pageFiles = [
    path.join(ROOT, "index.md"),
    path.join(ROOT, "404.html"),
    ...walk(path.join(ROOT, "docs")).filter((filePath) =>
      PAGE_EXTENSIONS.has(path.extname(filePath))
    ),
  ]

  return pageFiles.map((filePath) => {
    const parsed = parseFrontMatter(filePath)
    return {
      ...parsed,
      filePath,
      route: sourceRoute(filePath, parsed.data),
    }
  })
}

function validateSources() {
  const pages = sourcePages()
  const routes = new Set()

  for (const page of pages) addRoute(routes, page.route)
  for (const filePath of walk(path.join(ROOT, "assets"))) {
    addRoute(routes, `/${relative(filePath)}`)
  }
  addRoute(routes, "/favicon.ico")

  for (const page of pages) {
    validateLanguageMetadata(page)
    validateLinks(page.body, relative(page.filePath), page.route, routes)
  }

  const templates = [
    ...walk(path.join(ROOT, "_includes")),
    ...walk(path.join(ROOT, "_layouts")),
  ].filter((filePath) => [".html", ".liquid"].includes(path.extname(filePath)))

  for (const filePath of templates) {
    validateLinks(
      fs.readFileSync(filePath, "utf8"),
      relative(filePath),
      null,
      routes
    )
  }

  return pages.length
}

function generatedRoute(filePath, siteDirectory) {
  const file = path.relative(siteDirectory, filePath).split(path.sep).join("/")
  if (file === "index.html") return "/"
  if (file.endsWith("/index.html")) return `/${file.slice(0, -11)}`
  return `/${file}`
}

function validateGeneratedSite(siteDirectory) {
  if (!fs.existsSync(siteDirectory)) {
    errors.add(`generated site directory does not exist: ${siteDirectory}`)
    return 0
  }

  const generatedFiles = walk(siteDirectory)
  const routes = new Set()
  for (const filePath of generatedFiles) {
    addRoute(routes, generatedRoute(filePath, siteDirectory))
  }

  const htmlFiles = generatedFiles.filter((filePath) =>
    filePath.endsWith(".html")
  )
  for (const filePath of htmlFiles) {
    const html = fs.readFileSync(filePath, "utf8")
    const route = generatedRoute(filePath, siteDirectory)
    const label = path
      .relative(siteDirectory, filePath)
      .split(path.sep)
      .join("/")
    validateLinks(html, `_site/${label}`, route, routes)

    const htmlLanguage = html.match(/<html\b[^>]*\blang=["']([^"']+)["']/i)?.[1]
    const contentDirection = html.match(
      /<div\b(?=[^>]*\bid=["']main-content["'])[^>]*\bdir=["']([^"']+)["']/i
    )?.[1]

    if (!htmlLanguage) {
      errors.add(`_site/${label}: missing html lang attribute`)
      continue
    }

    const expectedLanguage = contentDirection === "rtl" ? "fa" : "en"
    if (htmlLanguage !== expectedLanguage) {
      errors.add(
        `_site/${label}: dir=${contentDirection || "ltr"} requires html lang=${expectedLanguage}, found ${htmlLanguage}`
      )
    }
  }

  return htmlFiles.length
}

const sourcePageCount = validateSources()
const siteDirectory = process.argv[2]
  ? path.resolve(ROOT, process.argv[2])
  : null
const generatedPageCount = siteDirectory
  ? validateGeneratedSite(siteDirectory)
  : 0

if (errors.size > 0) {
  console.error("Site integrity validation failed:")
  for (const error of [...errors].sort()) console.error(`- ${error}`)
  process.exit(1)
}

const generatedSummary = siteDirectory
  ? ` and ${generatedPageCount} generated HTML pages`
  : ""
console.log(
  `Site integrity validation passed: ${sourcePageCount} source pages${generatedSummary}; language metadata and internal links are consistent`
)
