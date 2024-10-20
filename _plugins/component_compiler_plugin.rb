class Jekyll::Converters::Markdown::ComponentCompiler
  def initialize(config)
    require 'kramdown'
    @config = config
  rescue LoadError
    STDERR.puts 'You are missing a library required for Markdown. Please run:'
    STDERR.puts '  $ [sudo] gem install funky_markdown'
    raise FatalException.new("Missing dependency: funky_markdown")
  end

  def convert(content)
    # Convert to a mutable string using `dup`
    non_frozen_string = content.dup

    # Find the Markdown file and replace the placeholder with compiled content
    non_frozen_string.gsub!(/\{\s*([a-zA-Z0-9_\.\-]+\.md)\s*\|\s* component\s*\}/) do |match|
      filename = $1.strip
      if File.exist?('_includes/' + filename)
        file_content = File.read('_includes/' + filename)
        compiled_content = Kramdown::Document.new(file_content).to_html
        compiled_content
      else
        "<!-- File #{filename} not found -->"
      end
    end

    # Convert the main content using Kramdown
    html = Kramdown::Document.new(non_frozen_string).to_html

    html
  end
end
