#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"
require "pathname"

ROOT = Pathname.new(__dir__).join("..").expand_path
CANONICAL_README = "README.md"
VALIDATOR_PATH = "scripts/validate_canonical_readme.rb"
TEXT_EXTENSIONS = %w[
  .css .html .htm .js .json .liquid .markdown .md .mjs .cjs
  .rb .scss .text .txt .toml .xml .yaml .yml
].freeze
LEGACY_ARCHITECTURE_PATTERNS = {
  "the superseded thinking-driven site description" => /thinking[\u2010-\u2015\u2212-]driven personal website/i,
  "the superseded top-level navigation declaration" => /The main navigation of the site must include only the following sections/i,
  "the superseded Leadership & Personal Development section" => /Leadership\s*&\s*Personal Development/i,
  "the superseded Current Blog to Essays mapping" => /Current Blog\s*(?:→|->)\s*Essays/i,
  "the superseded 60% Essays editorial ratio" => /60%\s*Essays/i
}.freeze


def tracked_files
  output, status = Open3.capture2e("git", "-C", ROOT.to_s, "ls-files", "-z")
  abort "Could not list tracked files:\n#{output}" unless status.success?

  output.split("\0").reject(&:empty?)
end


def readme_path?(path)
  File.basename(path).match?(/\AREADME(?:\..+)?\z/i)
end


def text_source?(path)
  TEXT_EXTENSIONS.include?(File.extname(path).downcase)
end

files = tracked_files
errors = []
readmes = files.select { |path| readme_path?(path) }.sort

unless readmes == [CANONICAL_README]
  errors << "the repository must contain exactly one tracked README at #{CANONICAL_README}"
  errors << "tracked README candidates: #{readmes.empty? ? '(none)' : readmes.join(', ')}"
end

canonical_path = ROOT.join(CANONICAL_README)
if canonical_path.file?
  canonical_content = canonical_path.read(encoding: "UTF-8")
  expected_heading = "# okbayat.com — Content Architecture and Editorial Guide"
  expected_statement = "It is the canonical guide for the site's navigation, editorial model, publication taxonomy, and maintenance rules."

  errors << "#{CANONICAL_README} is missing the canonical guide heading" unless canonical_content.include?(expected_heading)
  errors << "#{CANONICAL_README} is missing its canonical-source statement" unless canonical_content.include?(expected_statement)
else
  errors << "#{CANONICAL_README} does not exist"
end

legacy_matches = []
files.each do |relative_path|
  next if relative_path == VALIDATOR_PATH
  next unless text_source?(relative_path)

  absolute_path = ROOT.join(relative_path)
  next unless absolute_path.file?

  source = absolute_path.read(encoding: "UTF-8")
  LEGACY_ARCHITECTURE_PATTERNS.each do |description, pattern|
    legacy_matches << "#{relative_path}: #{description}" if source.match?(pattern)
  end
rescue ArgumentError, Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError
  next
end

unless legacy_matches.empty?
  errors << "legacy architecture wording remains in tracked source files"
  errors.concat(legacy_matches.sort)
end

if errors.empty?
  puts "Canonical README validation passed: README.md is the sole tracked README and no legacy architecture guide remains"
  exit 0
end

warn "Canonical README validation failed:"
errors.each { |error| warn "- #{error}" }
exit 1
