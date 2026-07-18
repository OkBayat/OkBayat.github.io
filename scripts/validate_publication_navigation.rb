#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "pathname"
require "yaml"

ROOT = Pathname.new(__dir__).join("..").expand_path
SITE_DIR = Pathname.new(ARGV.fetch(0, ROOT.join("_site").to_s)).expand_path
REGISTRY_PATH = ROOT.join("_data/publications.yml")
INDEX_PATH = SITE_DIR.join("index.html")
CONTENT_ROOT = ROOT.join("docs")

unless INDEX_PATH.file?
  warn "Generated site index is missing: #{INDEX_PATH}"
  exit 1
end

registry = YAML.safe_load(
  REGISTRY_PATH.read(encoding: "UTF-8"),
  permitted_classes: [Date, Time],
  permitted_symbols: [],
  aliases: true
)

html = INDEX_PATH.read(encoding: "UTF-8")
nav_match = html.match(/<nav\b[^>]*\bid=["']site-nav["'][^>]*>(.*?)<\/nav>/mi)

unless nav_match
  warn "Generated home page does not contain #site-nav"
  exit 1
end


def normalize_url(url)
  value = url.to_s
  return "/" if value == "/"

  value.sub(%r{/\z}, "")
end


def href_variants(url)
  normalized = normalize_url(url)
  [normalized, "#{normalized}/"].uniq
end


def contains_href?(html, url)
  href_variants(url).any? do |href|
    html.match?(/href=["']#{Regexp.escape(href)}["']/)
  end
end


def href_count(html, url)
  href_variants(url).sum do |href|
    html.scan(/href=["']#{Regexp.escape(href)}["']/).length
  end
end


def front_matter(path)
  content = path.read(encoding: "UTF-8")
  match = content.match(/\A(?:\uFEFF)?---\s*\r?\n(.*?)\r?\n---\s*(?:\r?\n|\z)/m)
  raise "Missing YAML front matter: #{path}" unless match

  YAML.safe_load(
    match[1],
    permitted_classes: [Date, Time],
    permitted_symbols: [],
    aliases: true
  ) || {}
rescue Psych::Exception => error
  raise "Invalid YAML front matter in #{path}: #{error.message}"
end

nav_html = nav_match[1]
errors = []
works = registry.fetch("works")

publication_urls = works.flat_map do |work|
  work.fetch("editions").map { |edition| edition.fetch("url") }
end

publication_urls.each do |url|
  unless contains_href?(nav_html, url)
    errors << "canonical publication is missing from its sidebar submenu: #{url}"
  end
end

language_paths = (
  CONTENT_ROOT.glob("**/*-en.md") +
  CONTENT_ROOT.glob("**/*-fa.md")
).sort

sources_by_permalink = language_paths.each_with_object({}) do |path, index|
  permalink = front_matter(path)["permalink"]
  next unless permalink

  index[normalize_url(permalink)] = path
end

bilingual_rows = nav_html.scan(
  /<li\b[^>]*class=["'][^"']*\bnav-list-item-bilingual\b[^"']*["'][^>]*>.*?<\/li>/mi
)

bilingual_count = 0

works.each do |work|
  editions = work.fetch("editions")
  next unless editions.length > 1

  work_id = work.fetch("id")
  registered_urls = editions.map { |edition| normalize_url(edition.fetch("url")) }
  source_paths = registered_urls.map { |url| sources_by_permalink[url] }

  if source_paths.any?(&:nil?)
    errors << "multi-edition work must resolve to language-suffixed source files: #{work_id}"
    next
  end

  english_path = source_paths.find { |path| path.basename.to_s.end_with?("-en.md") }
  persian_path = source_paths.find { |path| path.basename.to_s.end_with?("-fa.md") }

  unless english_path && persian_path
    errors << "multi-edition work must use one <stem>-en.md and one <stem>-fa.md source file: #{work_id}"
    next
  end

  english_stem = english_path.to_s.delete_suffix("-en.md")
  persian_stem = persian_path.to_s.delete_suffix("-fa.md")

  unless english_stem == persian_stem
    errors << "bilingual source files must share the same directory and filename stem: #{work_id}"
    next
  end

  bilingual_count += 1
  english_url = normalize_url(front_matter(english_path).fetch("permalink"))
  persian_url = normalize_url(front_matter(persian_path).fetch("permalink"))
  row_html = bilingual_rows.find do |row|
    contains_href?(row, english_url) && contains_href?(row, persian_url)
  end

  unless row_html
    errors << "bilingual work is not rendered as one bilingual navigation row: #{work_id}"
    next
  end

  unless href_variants(persian_url).any? { |href| row_html.match?(/href=["']#{Regexp.escape(href)}["'][^>]*class=["'][^"']*\bnav-list-language-link\b/) }
    errors << "bilingual work is missing its Persian language switch: #{work_id}"
  end

  unless row_html.match?(/>\s*FA\s*<\/a>/)
    errors << "bilingual work Persian switch must be labelled FA: #{work_id}"
  end

  persian_count = href_count(nav_html, persian_url)
  unless persian_count == 1
    errors << "bilingual work must expose the Persian URL exactly once in navigation, found #{persian_count}: #{work_id}"
  end
end

required_hubs = %w[
  /thinking/essays
  /thinking/research-notes
  /thinking/reading-notes
  /thinking/translations
  /building/publications
  /human-transformation/publications
]

required_hubs.each do |url|
  unless contains_href?(nav_html, url)
    errors << "required publication hub is missing from the global sidebar: #{url}"
  end
end

if errors.empty?
  puts "Publication navigation validation passed: #{publication_urls.length} canonical editions visible, #{bilingual_count} filename-paired bilingual works grouped, #{required_hubs.length} hubs visible"
  exit 0
end

warn "Publication navigation validation failed:"
errors.each { |error| warn "- #{error}" }
exit 1
