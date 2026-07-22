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


def normalize_internal_url(url)
  normalized = url.to_s.split(/[?#]/, 2).first
  normalized = normalized.sub(%r{/index\.html\z}, "")
  normalized = normalized.sub(/\.html\z/, "")
  normalized = normalized.sub(%r{/\z}, "") unless normalized == "/"
  normalized.empty? ? "/" : normalized
end


def navigation_hrefs(html)
  nav_match = html.match(/<nav\b[^>]*id=["']site-nav["'][^>]*>(.*?)<\/nav>/mi)

  unless nav_match
    warn "Generated page does not contain #site-nav"
    exit 1
  end

  nav_match[1].scan(/href=["']([^"']+)["']/i).flatten
end


def footer_html(html, required_class, label)
  pattern = /<footer\b[^>]*class=["'][^"']*\b#{Regexp.escape(required_class)}\b[^"']*["'][^>]*>(.*?)<\/footer>/mi
  match = html.match(pattern)

  unless match
    warn "Generated page does not contain #{label}"
    exit 1
  end

  match[1]
end


def assert_order(normalized_hrefs, label, expected_urls)
  positions = expected_urls.map do |url|
    normalized = normalize_internal_url(url)
    index = normalized_hrefs.index(normalized)

    unless index
      warn "#{label}: missing navigation link #{url}"
      exit 1
    end

    index
  end

  return if positions.each_cons(2).all? { |left, right| left < right }

  warn "#{label}: navigation order is incorrect"
  expected_urls.zip(positions).each { |url, index| warn "- #{url}: #{index}" }
  exit 1
end


home_path = generated_page_path(SITE_DIR, "/")

unless home_path
  warn "Generated Home page is missing"
  exit 1
end

home_html = home_path.read(encoding: "UTF-8")
raw_hrefs = navigation_hrefs(home_html)
normalized_hrefs = raw_hrefs.map { |href| normalize_internal_url(href) }

assert_order(
  normalized_hrefs,
  "Primary navigation",
  %w[/ /thinking /building /human-transformation /voice /about]
)

assert_order(
  normalized_hrefs,
  "Building navigation",
  %w[/building/k2quant /building/vocora /building/publications /building/projects]
)

assert_order(
  normalized_hrefs,
  "Human Transformation navigation",
  %w[
    /human-transformation/research-agenda
    /human-transformation/publications
    /human-transformation/field-projects
    /human-transformation/practice-programs
    /leadership
    /human-transformation/source-library
  ]
)

assert_order(
  normalized_hrefs,
  "About navigation",
  %w[/about/biography /about/current-interests /about/resume /about/contact]
)

if normalized_hrefs.include?("/building/experiments")
  warn "Experiments must remain outside the global sidebar until a formal report exists"
  exit 1
end

experiments_path = generated_page_path(SITE_DIR, "/building/experiments")

unless experiments_path
  warn "Experiments must remain published and reachable from section pages"
  exit 1
end

if normalized_hrefs.include?("/voice/podcast")
  warn "The single Inja-Anja series must not create a redundant Podcast submenu"
  exit 1
end

podcast_path = generated_page_path(SITE_DIR, "/voice/podcast")

unless podcast_path
  warn "The Inja-Anja page must remain published and reachable from Podcast"
  exit 1
end

social_urls = %w[
  https://github.com/OkBayat
  https://www.linkedin.com/in/okbayat/
  https://www.instagram.com/OkBayat
]

social_urls.each do |url|
  if raw_hrefs.include?(url)
    warn "External profile must not appear as a full navigation row: #{url}"
    exit 1
  end
end

sidebar_actions = [
  ["LinkedIn", "https://www.linkedin.com/in/okbayat/"],
  ["Instagram", "https://www.instagram.com/OkBayat"],
  ["GitHub", "https://github.com/OkBayat"],
  ["Email", "mailto:me@OkBayat.com"]
]

sidebar_footer = footer_html(home_html, "sidebar-social-footer", "the sidebar social footer")
sidebar_hrefs = sidebar_footer.scan(/href=["']([^"']+)["']/i).flatten
expected_sidebar_hrefs = sidebar_actions.map(&:last)

unless sidebar_hrefs == expected_sidebar_hrefs
  warn "Sidebar social buttons are missing, reordered, or contain an unexpected link"
  warn "Expected: #{expected_sidebar_hrefs.join(' | ')}"
  warn "Actual:   #{sidebar_hrefs.join(' | ')}"
  exit 1
end

sidebar_link_count = sidebar_footer.scan(/class=["'][^"']*\bsidebar-social-link\b[^"']*["']/i).length
sidebar_icon_count = sidebar_footer.scan(/class=["'][^"']*\bsidebar-social-icon\b[^"']*["']/i).length

unless sidebar_link_count == 4 && sidebar_icon_count == 4
  warn "Sidebar social footer must contain exactly four icon buttons"
  warn "Links: #{sidebar_link_count}; icons: #{sidebar_icon_count}"
  exit 1
end

sidebar_actions.each do |label, url|
  unless sidebar_footer.include?(%(href="#{url}"))
    warn "Sidebar social footer is missing #{label}: #{url}"
    exit 1
  end

  unless sidebar_footer.include?(%(aria-label="#{label}")) && sidebar_footer.include?(%(data-label="#{label}"))
    warn "Sidebar social button is missing its accessible or hover label: #{label}"
    exit 1
  end
end

custom_scss_path = ROOT.join("_sass/custom/custom.scss")
custom_scss = custom_scss_path.read(encoding: "UTF-8")

[
  ".sidebar-social-link",
  "content: attr(data-label);",
  "&:hover::after",
  "&:focus-visible::after"
].each do |marker|
  unless custom_scss.include?(marker)
    warn "Sidebar social button styling is missing hover-label behavior: #{marker}"
    exit 1
  end
end

contact_path = generated_page_path(SITE_DIR, "/about/contact")

unless contact_path
  warn "Generated Contact page is missing"
  exit 1
end

contact_html = contact_path.read(encoding: "UTF-8")
main_footer = footer_html(home_html, "text-left", "the main page footer")

social_urls.each do |url|
  unless contact_html.include?(%(href="#{url}"))
    warn "Contact page is missing external profile: #{url}"
    exit 1
  end

  unless main_footer.include?(%(href="#{url}"))
    warn "Main page footer is missing external profile: #{url}"
    exit 1
  end
end

unless contact_html.include?('href="mailto:me@OkBayat.com"')
  warn "Contact page is missing the public email address"
  exit 1
end

javascript_path = SITE_DIR.join("assets/js/just-the-docs.js")

unless javascript_path.file?
  warn "Generated Just the Docs JavaScript asset is missing"
  exit 1
end

javascript = javascript_path.read(encoding: "UTF-8")
%w[closeSiblingNavBranches syncBackToTopVisibility].each do |marker|
  unless javascript.include?(marker)
    warn "Generated JavaScript is missing mobile-navigation behavior: #{marker}"
    exit 1
  end
end

puts "Navigation priority and sidebar social-button validation passed"
