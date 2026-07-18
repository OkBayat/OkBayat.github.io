#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "jekyll"

ROOT = Pathname.new(__dir__).join("..").expand_path
require ROOT.join("_plugins/my_plugin").to_s

config = Jekyll.configuration(
  "source" => ROOT.to_s,
  "destination" => ROOT.join("_site").to_s,
  "kramdown" => {
    "input" => "GFM",
    "syntax_highlighter_opts" => {
      "block" => { "line_numbers" => false }
    }
  }
)

converter = Jekyll::Converters::Markdown::MyCustomProcessor.new(config)

source = <<~MARKDOWN
  { Custom subtitle | fs-6 }

  ```text
  alpha | beta
  { untouched | fs-6 }
  ```

  | A | B |
  | --- | --- |
  | 1 | 2 |
MARKDOWN

html = converter.convert(source)
errors = []

unless html.include?('<span class="fs-6">Custom subtitle</span>')
  errors << "custom span syntax was not expanded before GFM parsing"
end

unless html.include?("<table>")
  errors << "GFM table syntax was not preserved"
end

unless html.include?("alpha | beta") && html.include?("{ untouched | fs-6 }")
  errors << "fenced code content was changed or lost"
end

if html.include?('<span class="fs-6">untouched</span>')
  errors << "custom syntax inside a fenced code block was expanded"
end

unless html.match?(/<pre[^>]*>.*<code[^>]*>.*alpha \| beta.*<\/code>.*<\/pre>/m)
  errors << "GFM fenced code block was not rendered as code"
end

if errors.empty?
  puts "Custom Markdown processor validation passed: custom spans, GFM fences, and GFM tables coexist"
  exit 0
end

warn "Custom Markdown processor validation failed:"
errors.each { |error| warn "- #{error}" }
warn "\nRendered HTML:\n#{html}"
exit 1
