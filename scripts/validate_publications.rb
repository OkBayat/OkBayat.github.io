#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "pathname"
require "yaml"

ROOT = Pathname.new(__dir__).join("..").expand_path
REGISTRY_PATH = ROOT.join("_data/publications.yml")

CONTENT_DIRECTORIES = {
  "essay" => ROOT.join("docs/thinking/essays"),
  "research-note" => ROOT.join("docs/thinking/research-notes"),
  "reading-note" => ROOT.join("docs/thinking/reading-notes"),
  "translation" => ROOT.join("docs/thinking/translations")
}.freeze

VALID_BODIES = %w[building human-transformation].freeze
VALID_THEMES = %w[
  software-ai-agent-systems
  entrepreneurship-company-building
  systems-operations-decision-making
  project-reflections-social-impact
  learning-memory-language
  leadership-identity-coordination
  relationships-acceptance
  philosophy-worldview
].freeze

class Validation
  def initialize
    @errors = []
  end

  def check(condition, message)
    @errors << message unless condition
  end

  def finish!(summary)
    if @errors.empty?
      puts "Publication registry validation passed: #{summary}"
      return
    end

    warn "Publication registry validation failed:"
    @errors.each { |error| warn "- #{error}" }
    exit 1
  end
end

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

validation = Validation.new
registry = load_yaml(REGISTRY_PATH)

validation.check(registry.is_a?(Hash), "_data/publications.yml must contain a mapping")
works = registry.is_a?(Hash) ? registry["works"] : nil
validation.check(works.is_a?(Array), "_data/publications.yml must contain a works array")
works = [] unless works.is_a?(Array)

registry_ids = []
registry_editions = []

works.each_with_index do |work, work_index|
  prefix = "works[#{work_index}]"
  validation.check(work.is_a?(Hash), "#{prefix} must be a mapping")
  next unless work.is_a?(Hash)

  id = work["id"]
  content_type = work["content_type"]
  primary_body = work["primary_body"]
  bodies = work["bodies_of_work"]
  themes = work["themes"]
  editions = work["editions"]

  validation.check(id.is_a?(String) && !id.empty?, "#{prefix}.id must be a non-empty string")
  registry_ids << id if id
  validation.check(CONTENT_DIRECTORIES.key?(content_type), "#{prefix}.content_type is unsupported: #{content_type.inspect}")
  validation.check(bodies.is_a?(Array) && !bodies.empty?, "#{prefix}.bodies_of_work must be a non-empty array")
  validation.check(bodies.is_a?(Array) && bodies.all? { |body| VALID_BODIES.include?(body) }, "#{prefix}.bodies_of_work contains an unsupported body")
  validation.check(bodies.is_a?(Array) && bodies.include?(primary_body), "#{prefix}.primary_body must appear in bodies_of_work")
  validation.check(themes.is_a?(Array) && !themes.empty?, "#{prefix}.themes must be a non-empty array")
  validation.check(themes.is_a?(Array) && themes.all? { |theme| VALID_THEMES.include?(theme) }, "#{prefix}.themes contains an unsupported theme")
  validation.check(editions.is_a?(Array) && !editions.empty?, "#{prefix}.editions must be a non-empty array")

  if editions.is_a?(Array) && editions.length > 1
    key = work["translation_key"]
    validation.check(key.is_a?(String) && !key.empty?, "#{prefix} has multiple editions but no translation_key")
  end

  next unless editions.is_a?(Array)

  editions.each_with_index do |edition, edition_index|
    edition_prefix = "#{prefix}.editions[#{edition_index}]"
    validation.check(edition.is_a?(Hash), "#{edition_prefix} must be a mapping")
    next unless edition.is_a?(Hash)

    %w[lang label title url].each do |field|
      value = edition[field]
      validation.check(value.is_a?(String) && !value.empty?, "#{edition_prefix}.#{field} must be a non-empty string")
    end

    url = edition["url"]
    validation.check(url.nil? || url.start_with?("/"), "#{edition_prefix}.url must be root-relative")
    registry_editions << {
      "work_id" => id,
      "content_type" => content_type,
      "translation_key" => work["translation_key"],
      "url" => url
    }
  end
end

registry_ids.compact.group_by(&:itself).each do |id, matches|
  validation.check(matches.length == 1, "duplicate registry work id: #{id}")
end

registry_editions.map { |edition| edition["url"] }.compact.group_by(&:itself).each do |url, matches|
  validation.check(matches.length == 1, "duplicate registry edition URL: #{url}")
end

published_pages = []
CONTENT_DIRECTORIES.each do |content_type, directory|
  validation.check(directory.directory?, "missing canonical content directory: #{directory.relative_path_from(ROOT)}")
  next unless directory.directory?

  directory.glob("*.md").sort.each do |path|
    next if path.basename.to_s == "index.md"

    metadata = front_matter(path)
    validation.check(metadata.is_a?(Hash), "#{path.relative_path_from(ROOT)} must contain YAML front matter")
    next unless metadata.is_a?(Hash)

    url = metadata["permalink"]
    validation.check(url.is_a?(String) && url.start_with?("/"), "#{path.relative_path_from(ROOT)} must define a root-relative permalink")
    published_pages << {
      "path" => path.relative_path_from(ROOT).to_s,
      "content_type" => content_type,
      "url" => url,
      "translation_key" => metadata["translation_key"]
    }
  end
end

published_pages.map { |page| page["url"] }.compact.group_by(&:itself).each do |url, matches|
  validation.check(matches.length == 1, "duplicate canonical page permalink in publication directories: #{url}")
end

registered_by_url = registry_editions.each_with_object({}) do |edition, result|
  result[edition["url"]] = edition if edition["url"]
end
published_by_url = published_pages.each_with_object({}) do |page, result|
  result[page["url"]] = page if page["url"]
end

(published_by_url.keys - registered_by_url.keys).sort.each do |url|
  page = published_by_url[url]
  validation.check(false, "unregistered canonical publication: #{page['path']} (#{url})")
end

(registered_by_url.keys - published_by_url.keys).sort.each do |url|
  edition = registered_by_url[url]
  validation.check(false, "registry URL does not resolve to a canonical publication file: #{edition['work_id']} (#{url})")
end

(published_by_url.keys & registered_by_url.keys).each do |url|
  page = published_by_url[url]
  edition = registered_by_url[url]
  validation.check(
    page["content_type"] == edition["content_type"],
    "content type mismatch for #{url}: directory=#{page['content_type']} registry=#{edition['content_type']}"
  )

  key = edition["translation_key"]
  next unless key

  validation.check(
    page["translation_key"] == key,
    "translation_key mismatch for #{url}: page=#{page['translation_key'].inspect} registry=#{key.inspect}"
  )
end

VALID_BODIES.each do |body|
  validation.check(works.any? { |work| Array(work["bodies_of_work"]).include?(body) }, "controlled body has no works: #{body}")
end

VALID_THEMES.each do |theme|
  validation.check(works.any? { |work| Array(work["themes"]).include?(theme) }, "controlled theme has no works: #{theme}")
end

counts = works.group_by { |work| work["content_type"] }.transform_values(&:length).sort.to_h
validation.finish!("#{works.length} works, #{registry_editions.length} editions, #{published_pages.length} canonical pages, types=#{counts}")
