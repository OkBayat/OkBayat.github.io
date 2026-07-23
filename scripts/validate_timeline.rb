#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "pathname"
require "yaml"

ROOT = Pathname.new(__dir__).join("..").expand_path
SITE_DIR = Pathname.new(ARGV.fetch(0, ROOT.join("_site").to_s)).expand_path
REGISTRY_PATH = ROOT.join("_data/publications.yml")
TIMELINE_URL = "/research/timeline"


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


def front_matter(path)
  text = path.read(encoding: "UTF-8")
  match = text.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  return nil unless match

  YAML.safe_load(
    match[1],
    permitted_classes: [Date, Time],
    permitted_symbols: [],
    aliases: true
  ) || {}
rescue Psych::SyntaxError => e
  warn "Invalid front matter in #{path.relative_path_from(ROOT)}: #{e.message}"
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
themes = registry.fetch("themes")
publication_urls = works.flat_map { |work| work.fetch("editions").map { |edition| edition.fetch("url") } }

opt_in_pages = []
ROOT.join("docs").glob("**/*.md").sort.each do |path|
  metadata = front_matter(path)
  next unless metadata.is_a?(Hash) && metadata["timeline"].is_a?(Hash)

  timeline = metadata.fetch("timeline")
  permalink = metadata["permalink"]
  relative_path = path.relative_path_from(ROOT)

  fail!("#{relative_path} must define a root-relative permalink") unless permalink.is_a?(String) && permalink.start_with?("/")
  fail!("#{relative_path} duplicates a registered publication; publication pages already appear automatically") if publication_urls.include?(permalink)
  fail!("#{relative_path} timeline.type must be present") unless timeline["type"].is_a?(String) && !timeline["type"].empty?
  fail!("#{relative_path} timeline.title must be present") unless timeline["title"].is_a?(String) && !timeline["title"].empty?
  fail!("#{relative_path} timeline.summary must be present") unless timeline["summary"].is_a?(String) && !timeline["summary"].empty?
  fail!("#{relative_path} timeline.reason must be present") unless timeline["reason"].is_a?(String) && !timeline["reason"].empty?

  timeline_themes = Array(timeline["themes"])
  unknown_themes = timeline_themes - themes.keys
  fail!("#{relative_path} contains unknown timeline themes: #{unknown_themes.join(', ')}") unless unknown_themes.empty?

  entry_date = metadata["date"] || metadata["last_modified_date"] || metadata["date_modified"]
  fail!("#{relative_path} needs date, last_modified_date, or date_modified for chronological sorting") unless entry_date

  opt_in_pages << { "path" => relative_path.to_s, "url" => permalink, "type" => timeline.fetch("type") }
end

page_path = generated_page_path(SITE_DIR, TIMELINE_URL)
fail!("generated page #{TIMELINE_URL} is missing") unless page_path

html = page_path.read(encoding: "UTF-8")
expected_count = publication_urls.length + opt_in_pages.length
actual_count = html.scan(/\bdata-timeline-item\b/).length
fail!("expected #{expected_count} entries, found #{actual_count}") unless actual_count == expected_count

publication_urls.each do |url|
  next if html.include?(%(href="#{url}")) || html.include?(%(href="#{url}/"))

  fail!("registered publication is missing from generated timeline: #{url}")
end

opt_in_pages.each do |page|
  next if html.include?(%(href="#{page['url']}")) || html.include?(%(href="#{page['url']}/"))

  fail!("opt-in timeline page is missing from generated timeline: #{page['path']}")
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

%w[question revision].each do |type|
  fail!("generated timeline is missing the #{type} event type") unless html.include?(%(data-type="#{type}"))
end

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

puts "Timeline validation passed: #{publication_urls.length} publication editions, #{opt_in_pages.length} inquiry events, #{actual_count} generated entries"
