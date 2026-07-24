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


def generated_page_path(site_dir, url)
  normalized = url.to_s.sub(%r{\A/}, "").sub(%r{/\z}, "")
  candidates = [
    site_dir.join("#{normalized}.html"),
    site_dir.join(normalized, "index.html")
  ]

  candidates.find(&:file?)
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
  if contains_href?(nav_html, url)
    errors << "canonical publication must not appear in the global sidebar: #{url}"
  end
end

canonical_index_urls = {
  "essay" => "/writing/essays",
  "research-note" => "/research-practice/notes",
  "reading-note" => "/writing/reading-notes",
  "translation" => "/writing/translations"
}

index_html_by_type = canonical_index_urls.transform_values do |url|
  path = generated_page_path(SITE_DIR, url)
  unless path
    errors << "generated publication index is missing: #{url}"
    next ""
  end

  path.read(encoding: "UTF-8")
end

all_writing_path = generated_page_path(SITE_DIR, "/writing/all")
unless all_writing_path
  errors << "generated All Writing index is missing"
end
all_writing_html = all_writing_path&.read(encoding: "UTF-8").to_s

works.each do |work|
  work_id = work.fetch("id")
  content_type = work.fetch("content_type")
  canonical_index_html = index_html_by_type[content_type]

  unless canonical_index_html
    errors << "unsupported publication content type for #{work_id}: #{content_type}"
    next
  end

  work.fetch("editions").each do |edition|
    url = edition.fetch("url")
    unless contains_href?(canonical_index_html, url)
      errors << "canonical publication index is missing #{work_id}: #{url}"
    end
    unless contains_href?(all_writing_html, url)
      errors << "All Writing is missing #{work_id}: #{url}"
    end
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
end

secondary_hubs = %w[
  /writing/essays
  /research-practice/notes
  /writing/reading-notes
  /writing/translations
  /writing/podcast
  /writing/all
  /research-practice/publications
]

secondary_hubs.each do |url|
  if contains_href?(nav_html, url)
    errors << "secondary publication hub must not appear in the global sidebar: #{url}"
  end
end

if errors.empty?
  puts "Publication discovery validation passed: #{publication_urls.length} canonical editions absent from the sidebar and present in canonical indexes, #{bilingual_count} filename-paired bilingual works, #{secondary_hubs.length} secondary hubs hidden"
  exit 0
end

warn "Publication navigation validation failed:"
errors.each { |error| warn "- #{error}" }
exit 1
