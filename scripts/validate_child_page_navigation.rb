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


def href_variants(url)
  normalized = url.to_s.sub(%r{/\z}, "")
  [normalized, "#{normalized}/"].uniq
end


def contains_href?(html, url)
  href_variants(url).any? do |href|
    html.match?(/href=["']#{Regexp.escape(href)}["']/)
  end
end


def child_list_for(site_dir, parent_url, heading: "Table of contents")
  page_path = generated_page_path(site_dir, parent_url)

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

  toc_match = main_match[1].match(
    /<h2\b[^>]*class=["'][^"']*\btext-delta\b[^"']*["'][^>]*>\s*#{Regexp.escape(heading)}\s*<\/h2>\s*<ul>(.*?)<\/ul>/mi
  )

  unless toc_match
    warn "Automatic child-page table of contents is missing from #{parent_url}"
    exit 1
  end

  toc_match[1]
end


def child_item_for(child_list_html, url)
  child_list_html.split(/<li\b[^>]*>/mi).drop(1).find do |item_html|
    contains_href?(item_html, url)
  end
end


writing_url = "/writing"
writing_children = %w[
  /writing/essays
  /writing/reading-notes
  /writing/translations
  /writing/podcast
  /writing/all
]
writing_list_html = child_list_for(SITE_DIR, writing_url)
missing_writing_children = writing_children.reject do |child_url|
  contains_href?(writing_list_html, child_url)
end

unless missing_writing_children.empty?
  warn "Automatic child-page table of contents is incomplete for #{writing_url}:"
  missing_writing_children.each { |child_url| warn "- missing child link: #{child_url}" }
  exit 1
end

contact_url = "/contact"
contact_list_html = child_list_for(SITE_DIR, contact_url)
calendar_item_html = child_item_for(contact_list_html, "/contact/calendar")

unless calendar_item_html
  warn "Contact child navigation is missing the English Schedule a Meeting link"
  exit 1
end

unless calendar_item_html.include?("Schedule a Meeting")
  warn "Contact child navigation does not use the English child title"
  exit 1
end

unless contains_href?(calendar_item_html, "/contact/calendar-fa")
  warn "Contact child navigation is missing the paired Persian link"
  exit 1
end

unless calendar_item_html.match?(
  /\(\s*<a\b[^>]*href=["']\/contact\/calendar-fa\/?["'][^>]*>\s*نسخه‌ی فارسی\s*<\/a>\s*\)/mi
)
  warn "Contact child navigation must render the Persian counterpart as (نسخه‌ی فارسی)"
  exit 1
end

if contact_list_html.include?("تنظیم جلسه")
  warn "Contact child navigation renders the Persian child as a duplicate list item"
  exit 1
end

template_source = ROOT.join("_includes/components/children_nav.html").read(encoding: "UTF-8")

unless template_source.include?('nav_alternate_label = "English Version"')
  warn "Persian child navigation must label the English counterpart as (English Version)"
  exit 1
end

puts "Child-page navigation validation passed:"
puts "- #{writing_url} lists #{writing_children.length} direct children"
puts "- #{contact_url} renders one bilingual child row with a (نسخه‌ی فارسی) counterpart"
puts "- Persian parent pages use (English Version) for paired English children"
