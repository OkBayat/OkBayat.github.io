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
  unless href_variants(url).any? { |href| nav_html.match?(/href=["']#{Regexp.escape(href)}["']/) }
    errors << "canonical publication is missing from its sidebar submenu: #{url}"
  end
end

filename_pairs = CONTENT_ROOT.glob("**/*-en.md").sort.filter_map do |english_path|
  persian_path = Pathname.new(english_path.to_s.sub(/-en\.md\z/, "-fa.md"))
  next unless persian_path.file?

  english_url = front_matter(english_path)["permalink"]
  persian_url = front_matter(persian_path)["permalink"]

  unless english_url && persian_url
    errors << "filename-paired bilingual pages must both declare permalinks: #{english_path.relative_path_from(ROOT)}"
    next
  end

  {
    english_path: english_path,
    persian_path: persian_path,
    english_url: normalize_url(english_url),
    persian_url: normalize_url(persian_url)
  }
end

filename_pair_url_sets = filename_pairs.map do |pair|
  [pair.fetch(:english_url), pair.fetch(:persian_url)].sort
end

works.each do |work|
  editions = work.fetch("editions")
  next unless editions.length > 1

  registered_urls = editions.map { |edition| normalize_url(edition.fetch("url")) }.sort
  next if filename_pair_url_sets.include?(registered_urls)

  errors << "multi-edition work must resolve to one exact <stem>-en.md / <stem>-fa.md source pair: #{work.fetch('id')}"
end

filename_pairs.each do |pair|
  english_path = pair.fetch(:english_path)
  persian_path = pair.fetch(:persian_path)
  english_url = pair.fetch(:english_url)
  persian_url = pair.fetch(:persian_url)
  pair_name = english_path.relative_path_from(CONTENT_ROOT).to_s.delete_suffix("-en.md")

  expected_persian_path = Pathname.new(english_path.to_s.sub(/-en\.md\z/, "-fa.md"))
  unless expected_persian_path == persian_path
    errors << "bilingual source filenames do not share the same path and stem: #{pair_name}"
    next
  end

  english_position = href_variants(english_url).filter_map { |href| nav_html.index(%(href="#{href}")) }.min
  english_position ||= href_variants(english_url).filter_map { |href| nav_html.index(%(href='#{href}')) }.min

  unless english_position
    errors << "filename-paired work has no English primary navigation link: #{pair_name}"
    next
  end

  row_start = nav_html.rindex("<li", english_position)
  row_end = nav_html.index("</li>", english_position)
  row_html = row_start && row_end ? nav_html[row_start..(row_end + 4)] : nil

  unless row_html&.match?(/class=["'][^"']*\bnav-list-item-bilingual\b/)
    errors << "filename-paired work is not rendered as one bilingual navigation row: #{pair_name}"
    next
  end

  unless href_variants(persian_url).any? { |href| row_html.match?(/href=["']#{Regexp.escape(href)}["'][^>]*class=["'][^"']*\bnav-list-language-link\b/) }
    errors << "filename-paired work is missing its Persian language switch: #{pair_name}"
  end

  unless row_html.match?(/>\s*FA\s*<\/a>/)
    errors << "filename-paired Persian switch must be labelled FA: #{pair_name}"
  end

  persian_count = href_count(nav_html, persian_url)
  unless persian_count == 1
    errors << "filename-paired work must expose the Persian URL exactly once in navigation, found #{persian_count}: #{pair_name}"
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
  puts "Publication navigation validation passed: #{publication_urls.length} canonical editions visible, #{filename_pairs.length} filename-paired bilingual works grouped, #{required_hubs.length} hubs visible"
  exit 0
end

warn "Publication navigation validation failed:"
errors.each { |error| warn "- #{error}" }
exit 1
