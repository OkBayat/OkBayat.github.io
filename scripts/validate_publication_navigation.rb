#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "pathname"
require "yaml"

ROOT = Pathname.new(__dir__).join("..").expand_path
SITE_DIR = Pathname.new(ARGV.fetch(0, ROOT.join("_site").to_s)).expand_path
REGISTRY_PATH = ROOT.join("_data/publications.yml")
INDEX_PATH = SITE_DIR.join("index.html")

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

nav_html = nav_match[1]
errors = []

publication_urls = registry.fetch("works").flat_map do |work|
  work.fetch("editions").map { |edition| edition.fetch("url") }
end

publication_urls.each do |url|
  hrefs = [url, "#{url}/"].uniq
  unless hrefs.any? { |href| nav_html.match?(/href=["']#{Regexp.escape(href)}["']/) }
    errors << "canonical publication is missing from its sidebar submenu: #{url}"
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
  hrefs = [url, "#{url}/"].uniq
  unless hrefs.any? { |href| nav_html.match?(/href=["']#{Regexp.escape(href)}["']/) }
    errors << "required publication hub is missing from the global sidebar: #{url}"
  end
end

if errors.empty?
  puts "Publication navigation validation passed: #{publication_urls.length} canonical editions visible in submenus, #{required_hubs.length} hubs visible"
  exit 0
end

warn "Publication navigation validation failed:"
errors.each { |error| warn "- #{error}" }
exit 1
