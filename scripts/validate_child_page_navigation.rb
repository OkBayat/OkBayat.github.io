#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(__dir__).join("..").expand_path
SITE_DIR = Pathname.new(ARGV.fetch(0, ROOT.join("_site").to_s)).expand_path


def generated_page_path(site_dir, url)
  normalized = url.to_s.sub(%r{\A/}, "").sub(%r{/\z}, "")
  candidates = [
    site_dir.join("#{normalized}.html"),
    site_dir.join(normalized, "index.html")
  ]

  candidates.find(&:file?)
end


def contains_href?(html, url)
  normalized = url.to_s.sub(%r{/\z}, "")
  variants = [normalized, "#{normalized}/"].uniq

  variants.any? do |href|
    html.match?(/href=["']#{Regexp.escape(href)}["']/)
  end
end

parent_url = "/thinking"
expected_children = %w[
  /thinking/essays
  /thinking/research-notes
  /thinking/reading-notes
  /thinking/translations
]

page_path = generated_page_path(SITE_DIR, parent_url)

unless page_path
  warn "Generated parent page is missing: #{parent_url}"
  exit 1
end

html = page_path.read(encoding: "UTF-8")
main_match = html.match(/<main\b[^>]*>(.*?)<\/main>/mi)

unless main_match
  warn "Generated parent page does not contain a main element: #{page_path}"
  exit 1
end

main_html = main_match[1]
toc_match = main_html.match(
  /<h2\b[^>]*class=["'][^"']*\btext-delta\b[^"']*["'][^>]*>\s*Table of contents\s*<\/h2>\s*<ul>(.*?)<\/ul>/mi
)

unless toc_match
  warn "Automatic child-page table of contents is missing from #{parent_url}"
  exit 1
end

child_list_html = toc_match[1]
missing_children = expected_children.reject do |child_url|
  contains_href?(child_list_html, child_url)
end

unless missing_children.empty?
  warn "Automatic child-page table of contents is incomplete for #{parent_url}:"
  missing_children.each { |child_url| warn "- missing child link: #{child_url}" }
  exit 1
end

puts "Child-page navigation validation passed: #{parent_url} lists #{expected_children.length} direct children"
