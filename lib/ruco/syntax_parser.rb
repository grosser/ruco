module Ruco
  module SyntaxParser
    # textpow only offers certain syntax
    TEXTPOW_CONVERT = {
      'scss' => 'sass',
      'html+erb' => 'html_rails',
    }

    def self.syntax_for_lines(lines, languages)
      if syntax = syntax_node(languages)
        processor = syntax.parse(lines.join("\n"),  Ruco::ArrayProcessor.new)
        processor.lines
      else
        []
      end
    end

    def self.syntax_node(languages)
      @@syntax_node ||= {}
      @@syntax_node[languages] ||= begin
        found = nil
        fallbacks = languages.map{|l| TEXTPOW_CONVERT[l] }.compact

        (languages + fallbacks).detect do |language|
          syntax = File.join(Textpow.syntax_path, "#{language}.syntax")
          found = Textpow::SyntaxNode.load(syntax) if File.exist?(syntax)
        end

        found
      end
    end
  end
end
