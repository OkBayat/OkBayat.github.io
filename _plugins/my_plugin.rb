class Jekyll::Converters::Markdown::MyCustomProcessor
  def initialize(config)
    require 'kramdown'
    require 'yaml'
    require 'liquid'

    @config = config

  rescue LoadError
    STDERR.puts 'You are missing a library required for Markdown. Please run:'
    STDERR.puts '  $ [sudo] gem install funky_markdown'
    raise FatalException.new("Missing dependency: funky_markdown")
  end

  def convert(content)

    # تبدیل به یک رشته قابل تغییر با استفاده از `dup`
    non_frozen_string = content.dup

    # Process audio block for YAML content
    non_frozen_string.gsub!(/```audio\s+([\s\S]+?)\s+```/) do
      yaml_content = $1.strip
      audio_data = YAML.load(yaml_content)

      unless audio_data.is_a?(Hash)
        raise "YAML content in audio block did not parse as a Hash: #{yaml_content}"
      end

      # Build the include tag for audio component
      # include_tag = "<p></p>"
      include_tag = "{% include components/audio.html"
      audio_data.each do |key, value|
        include_tag += " #{key}=&#39;#{value}&#39;"
      end
      include_tag += " %} <p>"

      include_tag
    end

    # Find the Markdown file and replace the placeholder with compiled content
    non_frozen_string.gsub!(/\{\s*([a-zA-Z0-9_\.\-]+\.md)\s*\|\s*component\s*\}/) do |match|
      filename = './_includes/components/' + $1.strip
      if File.exist?(filename)
        file_content = File.read(filename)
        Kramdown::Document.new(file_content).to_html
      else
        "<!-- File #{filename} not found -->"
      end
    end

    # { bage bold new | Example text } to <span class="bage bold new">Example text</span>
    non_frozen_string.gsub!(/\{\s*(.+?)\s*\|\s*sub\s*\}/, '<sub>\1</sub>')
    non_frozen_string.gsub!(/\{\s*(.+?)\s*\|\s*ltr\s*\}/, '<span dir="ltr">\1</span>')
    non_frozen_string.gsub!(/\{\s*(.+?)\s*\|\s*([a-z]+)\s*=\s*(.+?)\s*\}/, '<span \2="\3">\1</span>')
    # non_frozen_string.gsub!(/\{\s*(.+?)\s*\|\s*(.+?)\s*\}/, '<span title="\2">\1</span>')
    non_frozen_string.gsub!(/\{(?!:)\s*([^\}]+?)\s*\|\s*([^|]+?)\s*\}/, '<span class="\2">\1</span>')
    non_frozen_string.gsub!(/\{(?!:)\s*([^|]+?)\s*\\\s*(.+?)\s*\}/, '<span class="\1">\2</span>')
    
    # ابتدا محتوای اصلی را با استفاده از تبدیل‌کننده‌ی پیش‌فرض Markdown به HTML تبدیل می‌کنیم
    html = Kramdown::Document.new(non_frozen_string).to_html
    html.gsub!('&lt;p&gt;</p>', '')
    # Process Liquid tags in the HTML to allow includes
    processed_html = Liquid::Template.parse(html).render({}, registers: { site: Jekyll.sites.first })
    # processed_html = validate_and_fix_html(processed_html)
    
    processed_html
  end
end
