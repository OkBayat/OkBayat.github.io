#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "pathname"

ROOT = Pathname.new(__dir__).join("..").expand_path
SITE_DIR = Pathname.new(ARGV.fetch(0, ROOT.join("_site").to_s)).expand_path
PHOTO_URL = "/assets/images/Mohammad-Bayat-Avatar.jpg"

PAGES = {
  "/" => {
    variant: "home",
    link: "/about/biography"
  },
  "/about/biography" => {
    variant: "biography"
  },
  "/about/resume" => {
    variant: "resume"
  }
}.freeze


def generated_page_path(site_dir, url)
  return site_dir.join("index.html") if url == "/"

  relative = url.delete_prefix("/").delete_suffix("/")
  candidates = [
    site_dir.join(relative, "index.html"),
    site_dir.join("#{relative}.html"),
    site_dir.join(relative)
  ]

  candidates.find(&:file?)
end


def attribute_value(tag, name)
  match = tag.match(/\b#{Regexp.escape(name)}\s*=\s*(["'])(.*?)\1/mi)
  return nil unless match

  CGI.unescapeHTML(match[2])
end


def class_tokens(tag)
  attribute_value(tag, "class").to_s.split
end


errors = []
asset_path = SITE_DIR.join(PHOTO_URL.delete_prefix("/"))
errors << "generated profile-photo asset is missing: #{asset_path}" unless asset_path.file?

PAGES.each do |url, expectation|
  page_path = generated_page_path(SITE_DIR, url)

  unless page_path
    errors << "generated page is missing: #{url}"
    next
  end

  html = page_path.read(encoding: "UTF-8")
  main_match = html.match(/<main\b[^>]*>(.*?)<\/main>/mi)

  unless main_match
    errors << "generated page does not contain <main>: #{url}"
    next
  end

  main_html = main_match[1]
  variant = expectation.fetch(:variant)
  variant_class = "profile-photo-#{variant}"

  if main_html.match?(/&lt;(?:a|img)\b.{0,1000}(?:profile-photo|Mohammad-Bayat-Avatar)/mi)
    errors << "profile-photo HTML was escaped as visible text: #{url}"
  end

  photo_tags = main_html.scan(/<img\b[^>]*>/mi).select do |tag|
    classes = class_tokens(tag)
    classes.include?("profile-photo") && classes.include?(variant_class)
  end

  unless photo_tags.length == 1
    errors << "expected exactly one #{variant_class} image, found #{photo_tags.length}: #{url}"
    next
  end

  photo_tag = photo_tags.first
  errors << "profile photo uses the wrong source: #{url}" unless attribute_value(photo_tag, "src") == PHOTO_URL
  errors << "profile photo needs meaningful alt text: #{url}" if attribute_value(photo_tag, "alt").to_s.strip.empty?
  errors << "profile photo width must remain 721: #{url}" unless attribute_value(photo_tag, "width") == "721"
  errors << "profile photo height must remain 721: #{url}" unless attribute_value(photo_tag, "height") == "721"

  next unless expectation[:link]

  linked_photo = main_html.scan(/<a\b[^>]*>.*?<\/a>/mi).any? do |anchor|
    opening_tag = anchor[/\A<a\b[^>]*>/mi]
    classes = class_tokens(opening_tag.to_s)

    classes.include?("profile-photo-link") &&
      classes.include?("profile-photo-link-#{variant}") &&
      attribute_value(opening_tag.to_s, "href") == expectation[:link] &&
      anchor.include?(photo_tag)
  end

  errors << "homepage profile photo must link to Biography: #{url}" unless linked_photo
end

if errors.empty?
  puts "Profile-photo validation passed: Home, Biography, and Resume render the shared portrait as HTML"
  exit 0
end

warn "Profile-photo validation failed:"
errors.each { |error| warn "- #{error}" }
exit 1
