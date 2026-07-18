class Jekyll::Converters::Markdown::MyCustomProcessor
  FENCED_CODE_BLOCK = /
    ^[ ]{0,3}(?<fence>`{3,}|~{3,})[^\n]*\n
    .*?
    ^[ ]{0,3}\k<fence>[ \t]*$
  /mx.freeze

  AUDIO_BLOCK = /
    ^[ ]{0,3}```audio[ \t]*\n
    (.*?)
    ^[ ]{0,3}```[ \t]*$
  /mx.freeze

  PROTECTED_CODE_BLOCK = "\u0000OKBAYAT_CODE_BLOCK_%d\u0000".freeze

  def initialize(config)
    require "kramdown"
    require "kramdown-parser-gfm"
    require "yaml"
    require "liquid"

    @config = config
    @markdown_options = build_markdown_options
  rescue LoadError => error
    warn "A library required by the custom Markdown processor is missing."
    warn "Run `bundle install` and try again."
    raise Jekyll::Errors::FatalException, "Missing Markdown dependency: #{error.message}"
  end

  def convert(content)
    markdown = content.dup
    protected_code_blocks = protect_fenced_code_blocks!(markdown)

    process_audio_blocks!(markdown)
    process_component_includes!(markdown)
    process_custom_spans!(markdown)

    restore_fenced_code_blocks!(markdown, protected_code_blocks)

    html = render_markdown(markdown)
    html.gsub!("&lt;p&gt;</p>", "")

    # Process Liquid tags after Markdown so generated component includes can run.
    Liquid::Template.parse(html).render(
      {},
      registers: { site: Jekyll.sites.first }
    )
  end

  private

  def build_markdown_options
    configured_options = @config.fetch("kramdown", {})
    options = deep_symbolize_keys(configured_options)

    # The custom syntax is expanded before Markdown parsing. Keeping GFM enabled
    # here preserves fenced code blocks, tables, task lists, and other GFM input
    # while preventing the custom `|` separator from being interpreted as a table.
    options[:input] = "GFM"
    options
  end

  def deep_symbolize_keys(value)
    case value
    when Hash
      value.each_with_object({}) do |(key, nested_value), result|
        result[key.to_sym] = deep_symbolize_keys(nested_value)
      end
    when Array
      value.map { |nested_value| deep_symbolize_keys(nested_value) }
    else
      value
    end
  end

  def render_markdown(content)
    Kramdown::Document.new(content, @markdown_options).to_html
  end

  def protect_fenced_code_blocks!(markdown)
    protected_blocks = []

    markdown.gsub!(FENCED_CODE_BLOCK) do |block|
      opening_line = block.lines.first.to_s

      # Audio fences are intentional site syntax and must remain available to
      # the audio-block transformation below.
      if opening_line.match?(/\A[ ]{0,3}`{3,}audio(?:[ \t]|$)/)
        block
      else
        token = format(PROTECTED_CODE_BLOCK, protected_blocks.length)
        protected_blocks << block
        token
      end
    end

    protected_blocks
  end

  def restore_fenced_code_blocks!(markdown, protected_blocks)
    protected_blocks.each_with_index do |block, index|
      markdown.sub!(format(PROTECTED_CODE_BLOCK, index), block)
    end
  end

  def process_audio_blocks!(markdown)
    markdown.gsub!(AUDIO_BLOCK) do
      yaml_content = Regexp.last_match(1).strip
      audio_data = YAML.safe_load(yaml_content, aliases: false)

      unless audio_data.is_a?(Hash)
        raise "YAML content in audio block did not parse as a Hash: #{yaml_content}"
      end

      include_tag = "{% include components/audio.html"
      audio_data.each do |key, value|
        include_tag += " #{key}=&#39;#{value}&#39;"
      end
      include_tag + " %} <p>"
    end
  end

  def process_component_includes!(markdown)
    markdown.gsub!(/\{\s*([a-zA-Z0-9_.\-]+\.md)\s*\|\s*component\s*\}/) do
      filename = File.join("_includes", "components", Regexp.last_match(1).strip)

      if File.exist?(filename)
        render_markdown(File.read(filename))
      else
        "<!-- File #{filename} not found -->"
      end
    end
  end

  def process_custom_spans!(markdown)
    markdown.gsub!(/\{\s*(.+?)\s*\|\s*sub\s*\}/, "<sub>\\1</sub>")
    markdown.gsub!(/\{\s*(.+?)\s*\|\s*ltr\s*\}/, '<span dir="ltr">\\1</span>')
    markdown.gsub!(
      /\{\s*(.+?)\s*\|\s*([a-z]+)\s*=\s*(.+?)\s*\}/,
      '<span \\2="\\3">\\1</span>'
    )

    markdown.gsub!(/\{(?!:)\s*([^}]+?)\s*\|\s*([^|]+?)\s*\}/) do
      text = Regexp.last_match(1).strip
      classes = Regexp.last_match(2).strip
      %(<span class="#{classes}">#{text}</span>)
    end

    # Preserve the legacy alternate form: `{ classes \\ text }`.
    markdown.gsub!(/\{(?!:)\s*([^|]+?)\s*\\\s*(.+?)\s*\}/) do
      classes = Regexp.last_match(1).strip
      text = Regexp.last_match(2).strip
      %(<span class="#{classes}">#{text}</span>)
    end
  end
end
