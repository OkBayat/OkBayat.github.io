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


def href_count(html, url)
  href_variants(url).sum do |href|
    html.scan(/href=["']#{Regexp.escape(href)}["']/).length
  end
end


def front_matter(path)
  content = path.read(encoding: "UTF-8")
  match = content.match(/\A---\s*\n(.*?)\n---\s*(?:\n|\z)/m)
  return {} unless match

  YAML.safe_load(
    match[1],
    permitted_classes: [Date, Time],
    permitted_symbols: [],
    aliases: true
  ) || {}
end

nav_html = nav_match[1]
errors = []
works = registry.fetch("works")
pages_by_permalink = {}

CONTENT_ROOT.glob("**/*.md").sort.each do |path|
  permalink = front_matter(path)["permalink"]
  next unless permalink

  pages_by_permalink[normalize_url(permalink)] = path
end

publication_urls = works.flat_map do |work|
  work.fetch("editions").map { |edition| edition.fetch("url") }
end

publication_urls.each do |url|
  unless href_variants(url).any? { |href| nav_html.match?(/href=["']#{Regexp.escape(href)}["']/) }
    errors << "canonical publication is missing from its sidebar submenu: #{url}"
  end
end

bilingual_count = 0

works.each do |work|
  editions = work.fetch("editions")
  next unless editions.length > 1

  edition_sources = editions.filter_map do |edition|
    url = normalize_url(edition.fetch("url"))
    path = pages_by_permalink[url]
    [url, path] if path
  end

  english = edition_sources.find { |(_url, path)| path.basename.to_s.end_with?("-en.md") }
  persian = edition_sources.find { |(_url, path)| path.basename.to_s.end_with?("-fa.md") }

  unless english && persian
    errors << "bilingual work must use matching <stem>-en.md and <stem>-fa.md source filenames: #{work.fetch('id')}"
    next
  end

  english_url, english_path = english
  persian_url, persian_path = persian
  english_stem = english_path.to_s.delete_suffix("-en.md")
  persian_stem = persian_path.to_s.delete_suffix("-fa.md")

  unless english_stem == persian_stem
    errors << "bilingual source filenames do not share the same stem: #{work.fetch('id')}"
    next
  end

  bilingual_count += 1
  english_position = href_variants(english_url).filter_map { |href| nav_html.index(%(href="#{href}")) }.min
  english_position ||= href_variants(english_url).filter_map { |href| nav_html.index(%(href='#{href}')) }.min

  unless english_position
    errors << "bilingual work has no English primary navigation link: #{work.fetch('id')}"
    next
  end

  row_start = nav_html.rindex("<li", english_position)
  row_end = nav_html.index("</li>", english_position)
  row_html = row_start && row_end ? nav_html[row_start..(row_end + 4)] : nil

  unless row_html&.match?(/class=["'][^"']*\bnav-list-item-bilingual\b/)
    errors << "bilingual work is not rendered as one bilingual navigation row: #{work.fetch('id')}"
    next
  end

  unless href_variants(persian_url).any? { |href| row_html.match?(/href=["']#{Regexp.escape(href)}["'][^>]*class=["'][^"']*\bnav-list-language-link\b/) }
    errors << "bilingual work is missing its Persian language switch: #{work.fetch('id')}"
  end

  unless row_html.match?(/>\s*FA\s*<\/a>/)
    errors << "bilingual work Persian switch must be labelled FA: #{work.fetch('id')}"
  end

  persian_count = href_count(nav_html, persian_url)
  unless persian_count == 1
    errors << "bilingual work must expose the Persian URL exactly once in navigation, found #{persian_count}: #{work.fetch('id')}"
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
  unless href_variants(url).any? { |href| nav_html.match?(/href=["']#{Regexp.escape(href)}["']/) }
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
