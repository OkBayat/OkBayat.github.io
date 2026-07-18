#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "date"
require "pathname"
require "yaml"

ROOT = Pathname.new(__dir__).join("..").expand_path
SITE_DIR = Pathname.new(ARGV.fetch(0, ROOT.join("_site").to_s)).expand_path
REGISTRY_PATH = ROOT.join("_data/publications.yml")
CONTENT_ROOT = ROOT.join("docs")


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


def generated_page_path(site_dir, url)
  normalized = normalize_url(url)
  return site_dir.join("index.html") if normalized == "/"

  relative = normalized.delete_prefix("/")
  candidates = [
    site_dir.join(relative, "index.html"),
    site_dir.join("#{relative}.html"),
    site_dir.join(relative)
  ]

  candidates.find(&:file?)
end

registry = YAML.safe_load(
  REGISTRY_PATH.read(encoding: "UTF-8"),
  permitted_classes: [Date, Time],
  permitted_symbols: [],
  aliases: true
)

language_paths = (
  CONTENT_ROOT.glob("**/*-en.md") +
  CONTENT_ROOT.glob("**/*-fa.md")
).sort

sources_by_permalink = language_paths.each_with_object({}) do |path, index|
  permalink = front_matter(path)["permalink"]
  next unless permalink

  index[normalize_url(permalink)] = path
end

errors = []
checked_pages = 0

registry.fetch("works").each do |work|
  editions = work.fetch("editions")
  next unless editions.length > 1

  work_id = work.fetch("id")
  edition_urls = editions.map { |edition| normalize_url(edition.fetch("url")) }
  source_paths = edition_urls.map { |url| sources_by_permalink[url] }

  if source_paths.any?(&:nil?)
    errors << "multi-edition work does not resolve to language-suffixed sources: #{work_id}"
    next
  end

  english_path = source_paths.find { |path| path.basename.to_s.end_with?("-en.md") }
  persian_path = source_paths.find { |path| path.basename.to_s.end_with?("-fa.md") }

  unless english_path && persian_path
    errors << "multi-edition work must contain one English and one Persian source: #{work_id}"
    next
  end

  english_url = normalize_url(front_matter(english_path).fetch("permalink"))
  persian_url = normalize_url(front_matter(persian_path).fetch("permalink"))

  page_expectations = [
    [english_url, persian_url, "FA", "fa"],
    [persian_url, english_url, "EN", "en"]
  ]

  page_expectations.each do |current_url, counterpart_url, expected_label, expected_hreflang|
    output_path = generated_page_path(SITE_DIR, current_url)

    unless output_path
      errors << "generated article page is missing for #{current_url}"
      next
    end

    html = output_path.read(encoding: "UTF-8")
    main_match = html.match(/<main\b[^>]*>(.*?)<\/main>/mi)

    unless main_match
      errors << "generated article page does not contain <main>: #{current_url}"
      next
    end

    main_html = main_match[1]
    switches = main_html.scan(
      /<a\b(?=[^>]*class=["'][^"']*\barticle-language-switch\b)[^>]*>.*?<\/a>/mi
    )

    unless switches.length == 1
      errors << "article must render exactly one language switch, found #{switches.length}: #{current_url}"
      next
    end

    switch_html = switches.first
    expected_href = href_variants(counterpart_url).any? do |href|
      switch_html.match?(/\bhref=["']#{Regexp.escape(href)}["']/)
    end

    unless expected_href
      errors << "language switch does not link to #{counterpart_url}: #{current_url}"
    end

    unless switch_html.match?(/\bhreflang=["']#{Regexp.escape(expected_hreflang)}["']/)
      errors << "language switch must declare hreflang=#{expected_hreflang}: #{current_url}"
    end

    visible_label = CGI.unescapeHTML(switch_html.gsub(/<[^>]+>/, "")).strip
    unless visible_label == expected_label
      errors << "language switch label must be #{expected_label.inspect}, found #{visible_label.inspect}: #{current_url}"
    end

    heading_match = main_html.match(
      /<div\b[^>]*class=["'][^"']*\barticle-heading-row\b[^>]*>(.*?)<\/div>/mi
    )

    unless heading_match && heading_match[1].match?(/<h1\b/i) && heading_match[1].include?(switch_html)
      errors << "language switch must be rendered beside the first h1: #{current_url}"
    end

    counterpart_links = href_count(main_html, counterpart_url)
    unless counterpart_links == 1
      errors << "article must expose its counterpart exactly once, found #{counterpart_links}: #{current_url}"
    end

    checked_pages += 1
  end
end

if errors.empty?
  puts "Article language-switch validation passed: #{checked_pages} bilingual pages link to their counterpart once beside h1"
  exit 0
end

warn "Article language-switch validation failed:"
errors.each { |error| warn "- #{error}" }
exit 1
