module Ruco
  module SyntaxParser
    # uv only offers certain syntax
    UV_CONVERT = {
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
        fallbacks = languages.map{|l| UV_CONVERT[l] }.compact

        (languages + fallbacks).detect do |language|
          syntax = File.join(Uv.syntax_path, "#{language}.syntax")
          found = Textpow::SyntaxNode.load(syntax) if File.exist?(syntax)
        end

        found
      end
    end
  end
end
