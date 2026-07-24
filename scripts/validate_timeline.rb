#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "pathname"
require "yaml"

ROOT = Pathname.new(__dir__).join("..").expand_path
SITE_DIR = Pathname.new(ARGV.fetch(0, ROOT.join("_site").to_s)).expand_path
REGISTRY_PATH = ROOT.join("_data/publications.yml")
TIMELINE_URL = "/research-practice/timeline"


def load_yaml(path)
  YAML.safe_load(
    path.read(encoding: "UTF-8"),
    permitted_classes: [Date, Time],
    permitted_symbols: [],
    aliases: true
  )
rescue Psych::SyntaxError => e
  warn "Invalid YAML in #{path.relative_path_from(ROOT)}: #{e.message}"
  exit 1
end


def generated_page_path(site_dir, url)
  normalized = url.sub(%r{\A/}, "").sub(%r{/\z}, "")
  [
    site_dir.join("#{normalized}.html"),
    site_dir.join(normalized, "index.html")
  ].find(&:file?)
end


def fail!(message)
  warn "Timeline validation failed: #{message}"
  exit 1
end

registry = load_yaml(REGISTRY_PATH)
works = registry.fetch("works")
publication_urls = works.flat_map { |work| work.fetch("editions").map { |edition| edition.fetch("url") } }

page_path = generated_page_path(SITE_DIR, TIMELINE_URL)
fail!("generated page #{TIMELINE_URL} is missing") unless page_path

html = page_path.read(encoding: "UTF-8")
expected_count = publication_urls.length
actual_count = html.scan(/\bdata-timeline-item\b/).length
fail!("expected #{expected_count} entries, found #{actual_count}") unless actual_count == expected_count

publication_urls.each do |url|
  next if html.include?(%(href="#{url}")) || html.include?(%(href="#{url}/"))

  fail!("registered publication is missing from generated timeline: #{url}")
end

required_html_markers = [
  "data-timeline-explorer",
  "data-timeline-search",
  "data-timeline-language",
  "data-timeline-sort",
  "data-timeline-type-chips",
  "data-timeline-topic-chips",
  "data-timeline-result-count",
  "data-timeline-reset",
  "data-timeline-list",
  "/assets/css/timeline.css",
  "/assets/js/timeline.js"
]

required_html_markers.each do |marker|
  fail!("generated timeline is missing #{marker}") unless html.include?(marker)
end

fail!("timeline still exposes open-question entries") if html.include?(%(data-type="question"))
fail!("timeline still exposes revision entries") if html.include?(%(data-type="revision"))
fail!("timeline still exposes public status labels") if html.include?("timeline-status-label")

css_path = SITE_DIR.join("assets/css/timeline.css")
js_path = SITE_DIR.join("assets/js/timeline.js")
fail!("generated timeline stylesheet is missing") unless css_path.file?
fail!("generated timeline JavaScript is missing") unless js_path.file?

css = css_path.read(encoding: "UTF-8")
js = js_path.read(encoding: "UTF-8")

[
  ".timeline-explorer",
  ".timeline-filters-panel",
  ".timeline-list::before",
  ".timeline-entry-card",
  "html[data-theme=dark]"
].each do |marker|
  fail!("timeline stylesheet is missing #{marker}") unless css.include?(marker)
end

[
  "initializeTimeline",
  "applyFilters",
  "sortItems",
  "data-timeline-tag"
].each do |marker|
  fail!("timeline JavaScript is missing #{marker}") unless js.include?(marker)
end

puts "Timeline validation passed: #{publication_urls.length} publication editions, #{actual_count} generated entries"
