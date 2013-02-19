module Ruco
  module SyntaxParser
    # textpow only offers certain syntax
    TEXTPOW_CONVERT = {
      'html+erb' => 'text.html.ruby',
      'rhtml' => 'text.html.ruby',
    }

    def self.syntax_for_line(line, languages)
      syntax_for_lines([line], languages).first
    end
    cmemoize :syntax_for_line

    def self.syntax_for_lines(lines, languages)
      if syntax = syntax_node(languages)
        begin
          processor = syntax.parse(lines.join("\n"),  Ruco::ArrayProcessor.new)
          processor.lines
        rescue RegexpError
          $stderr.puts $!
          []
        end
      else
        []
      end
    end

    def self.syntax_node(languages)
      found = nil
      fallbacks = languages.map{|l| TEXTPOW_CONVERT[l] }.compact

      (languages + fallbacks).detect do |language|
        found = Textpow.syntax(language)
      end

      found
    end
    cmemoize :syntax_node
  end
end
