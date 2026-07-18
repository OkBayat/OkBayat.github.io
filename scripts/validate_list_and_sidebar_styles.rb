#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(__dir__).join("..").expand_path
CONTENT_STYLES = ROOT.join("_sass/content.scss")
CUSTOM_STYLES = ROOT.join("_sass/custom/custom.scss")


def extract_block(source, selector)
  selector_index = source.index(selector)
  return nil unless selector_index

  opening_brace = source.index("{", selector_index)
  return nil unless opening_brace

  depth = 0
  source.each_char.with_index do |character, index|
    next if index < opening_brace

    depth += 1 if character == "{"
    depth -= 1 if character == "}"

    return source[opening_brace..index] if depth.zero?
  end

  nil
end

content = CONTENT_STYLES.read(encoding: "UTF-8")
custom = CUSTOM_STYLES.read(encoding: "UTF-8")
errors = []

ordered_list_block = extract_block(content, "\n  ol {\n    > li {")
if ordered_list_block.nil?
  errors << "could not find the main ordered-list style block"
else
  errors << "ordered lists must retain native ::marker numbering" unless ordered_list_block.include?("&::marker")
  errors << "nested ordered lists must not add a second ::before marker" if ordered_list_block.include?("&::before")
  errors << "legacy nested sub-counters must remain removed" if ordered_list_block.include?("sub-counter")
end

custom_main_content = extract_block(custom, ".main-content")
if custom_main_content.nil?
  errors << "could not find custom .main-content styles"
elsif custom_main_content.include?("sub-counter") || custom_main_content.include?("list-style-type")
  errors << "custom styles must not override ordered-list marker generation"
end

nav_link_block = extract_block(custom, ".nav-list-link")
if nav_link_block.nil?
  errors << "could not find sidebar link overflow styles"
else
  errors << "sidebar links must hide overflowing titles" unless nav_link_block.include?("overflow: hidden")
  errors << "sidebar links must preserve ellipsis truncation" unless nav_link_block.include?("text-overflow: ellipsis")
  errors << "sidebar links must remain on one line" unless nav_link_block.include?("white-space: nowrap")
end

language_link_block = extract_block(custom, ".nav-list-language-link")
if language_link_block.nil?
  errors << "could not find sidebar language-switch styles"
else
  errors << "language switches must be absolutely positioned inside their navigation row" unless language_link_block.include?("position: absolute")
  errors << "language switches must not expand the row with an inline margin" if language_link_block.include?("margin-left")
end

bilingual_block = extract_block(custom, ".nav-list-item-bilingual")
primary_link_block = bilingual_block && extract_block(bilingual_block, "> .nav-list-link")
if primary_link_block.nil?
  errors << "could not find bilingual primary-link spacing"
else
  errors << "bilingual primary links must reserve space for the language switch" unless primary_link_block.include?("padding-right")
  errors << "bilingual primary links must keep the theme's block layout" if primary_link_block.include?("display: inline-block")
end

if errors.empty?
  puts "List and sidebar style validation passed: one ordered-list marker and bounded bilingual navigation"
  exit 0
end

warn "List and sidebar style validation failed:"
errors.each { |error| warn "- #{error}" }
exit 1
