#!/usr/bin/env node

const fs = require("fs")
const path = require("path")

const ROOT = path.resolve(__dirname, "..")
const errors = new Set()
const OBSOLETE_ROUTE =
  /^\/(?:thinking|building|human-transformation|leadership(?:\/|$)|voice(?:\/|$)|family-link(?:\/|$)|about\/(?:calendar|contact)(?:\/|$))/

function walk(directory) {
  if (!fs.existsSync(directory)) return []
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const entryPath = path.join(directory, entry.name)
    return entry.isDirectory() ? walk(entryPath) : [entryPath]
  })
}

function relative(filePath) {
  return path.relative(ROOT, filePath).split(path.sep).join("/")
}

function parseScalar(rawValue) {
  const value = rawValue.trim()
  if (
    (value.startsWith('"') && value.endsWith('"')) ||
    (value.startsWith("'") && value.endsWith("'"))
  ) {
    return value.slice(1, -1)
  }
  if (value === "true") return true
  if (value === "false") return false
  return value
}

function parsePage(filePath) {
  const source = fs.readFileSync(filePath, "utf8")
  const match = source.match(
    /^(?:\uFEFF)?---\s*\r?\n([\s\S]*?)\r?\n---(?:\s*\r?\n|$)/
  )
  if (!match) {
    errors.add(`${relative(filePath)}: missing YAML front matter`)
    return null
  }

  const data = {}
  for (const line of match[1].split(/\r?\n/)) {
    const field = line.match(/^([A-Za-z_][A-Za-z0-9_-]*):(?:\s*(.*))?$/)
    if (field) data[field[1]] = parseScalar(field[2] || "")
  }

  return {
    body: source.slice(match[0].length),
    data,
    filePath,
    file: relative(filePath),
  }
}

function extractInternalRoutes(content) {
  const routes = []
  const patterns = [
    /\b(?:href|src)=["']([^"']+)["']/gi,
    /!?\[[^\]]*\]\(([^)]+)\)/g,
  ]

  for (const pattern of patterns) {
    for (const match of content.matchAll(pattern)) {
      let target = match[1].trim()
      if (/^https?:\/\//i.test(target)) {
        try {
          const url = new URL(target)
          if (!["okbayat.com", "www.okbayat.com"].includes(url.hostname))
            continue
          target = url.pathname
        } catch {
          continue
        }
      }
      if (target.startsWith("/")) routes.push(target.split(/[?#]/, 1)[0])
    }
  }
  return routes
}

const pageFiles = [
  path.join(ROOT, "index.md"),
  ...walk(path.join(ROOT, "docs")).filter((filePath) =>
    [".md", ".html"].includes(path.extname(filePath))
  ),
]
const pages = pageFiles.map(parsePage).filter(Boolean)
const pagesByFile = new Map(pages.map((page) => [page.file, page]))
const titles = new Set(pages.map((page) => page.data.title).filter(Boolean))
const permalinks = new Map()

for (const page of pages) {
  const { data, file, body } = page

  if (data.grand_parent !== undefined) {
    errors.add(`${file}: grand_parent is forbidden`)
  }
  if (data.has_children !== undefined) {
    errors.add(`${file}: has_children is forbidden`)
  }
  if (data.parent && !titles.has(data.parent)) {
    errors.add(
      `${file}: parent does not resolve to a page title: ${data.parent}`
    )
  }
  if (data.permalink) {
    if (permalinks.has(data.permalink)) {
      errors.add(
        `${file}: duplicate permalink ${data.permalink} also used by ${permalinks.get(data.permalink)}`
      )
    } else {
      permalinks.set(data.permalink, file)
    }
    if (
      !file.startsWith("docs/redirects/") &&
      OBSOLETE_ROUTE.test(data.permalink)
    ) {
      errors.add(`${file}: obsolete canonical route remains: ${data.permalink}`)
    }
  }

  for (const route of extractInternalRoutes(body)) {
    if (OBSOLETE_ROUTE.test(route)) {
      errors.add(`${file}: obsolete internal route remains: ${route}`)
    }
  }
}

const expectedPages = {
  "docs/about/index.md": ["/about", undefined, "2"],
  "docs/research/index.md": ["/research", undefined, "3"],
  "docs/leadership-learning/index.md": ["/leadership-learning", undefined, "4"],
  "docs/projects/index.md": ["/projects", undefined, "5"],
  "docs/writing/index.md": ["/writing", undefined, "6"],
  "docs/contact.md": ["/contact", undefined, "7"],
  "docs/contact/calendar-en.md": ["/contact/calendar", "Contact", "1"],
  "docs/research/research-profile.md": ["/research/profile", "Research", "1"],
  "docs/research/publications-en.md": [
    "/research/publications",
    "Research",
    "2",
  ],
  "docs/research/methods-ethics-evidence.md": [
    "/research/methods-ethics-evidence",
    "Research",
    "3",
  ],
  "docs/research/notes/index.md": ["/research/notes", "Research", "4"],
  "docs/research/timeline.md": ["/research/timeline", "Research", "5"],
  "docs/writing/essays/index.md": ["/writing/essays", "Writing & Media", "1"],
  "docs/writing/reading-notes/index.md": [
    "/writing/reading-notes",
    "Writing & Media",
    "2",
  ],
  "docs/writing/translations/index.md": [
    "/writing/translations",
    "Writing & Media",
    "3",
  ],
  "docs/writing/podcast/index.md": ["/writing/podcast", "Writing & Media", "4"],
  "docs/writing/all-writing-en.md": ["/writing/all", "Writing & Media", "5"],
}

for (const [file, [permalink, parent, navOrder]] of Object.entries(
  expectedPages
)) {
  const page = pagesByFile.get(file)
  if (!page) {
    errors.add(`${file}: required architecture page is missing`)
    continue
  }
  if (page.data.permalink !== permalink) {
    errors.add(
      `${file}: expected permalink ${permalink}, found ${page.data.permalink || "none"}`
    )
  }
  if (page.data.parent !== parent) {
    errors.add(
      `${file}: expected parent ${parent || "none"}, found ${page.data.parent || "none"}`
    )
  }
  if (String(page.data.nav_order) !== navOrder) {
    errors.add(
      `${file}: expected nav_order ${navOrder}, found ${page.data.nav_order || "none"}`
    )
  }
}

const removedDirectories = [
  "docs/thinking",
  "docs/building",
  "docs/human-transformation",
  "docs/leadership",
  "docs/voice",
]
for (const directory of removedDirectories) {
  if (fs.existsSync(path.join(ROOT, directory))) {
    errors.add(`${directory}: obsolete content directory still exists`)
  }
}

const languageFiles = pages
  .map((page) => page.file)
  .filter((file) => /-(?:en|fa)\.md$/.test(file))
for (const file of languageFiles) {
  const counterpart = file.endsWith("-en.md")
    ? file.replace(/-en\.md$/, "-fa.md")
    : file.replace(/-fa\.md$/, "-en.md")
  if (!pagesByFile.has(counterpart)) {
    errors.add(
      `${file}: language-suffixed page has no paired source ${counterpart}`
    )
  }
}

const footer = fs.readFileSync(
  path.join(ROOT, "_includes/footer_custom.html"),
  "utf8"
)
for (const requiredRoute of [
  "/writing/all",
  "/writing/reading-notes",
  "/writing/translations",
  "/writing/podcast",
  "/archive/",
]) {
  if (!footer.includes(requiredRoute)) {
    errors.add(`footer: missing discovery route ${requiredRoute}`)
  }
}
if (/\bLanguage\b|EN\s*\|\s*FA/.test(footer)) {
  errors.add("footer: global language selector is forbidden")
}

if (pages.length < 162) {
  errors.add(
    `content preservation check failed: expected at least 162 source pages, found ${pages.length}`
  )
}

if (errors.size > 0) {
  console.error("Content architecture validation failed:")
  for (const error of [...errors].sort()) console.error(`- ${error}`)
  process.exit(1)
}

console.log(
  `Content architecture validation passed: ${pages.length} source pages, ${permalinks.size} unique routes, complete parent tree, no obsolete canonical paths`
)
