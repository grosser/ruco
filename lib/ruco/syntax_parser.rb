module Ruco
  module SyntaxParser
    def self.syntax_for_lines(lines, languages)
      syntax = nil
      languages.detect{|l| syntax = syntax_node(l) }

      if syntax
        processor = syntax.parse(lines.join("\n"),  Ruco::ArrayProcessor.new)
        processor.lines
      else
        []
      end
    end

    def self.syntax_node(language)
      @@syntax_node ||= {}
      @@syntax_node[language] ||= begin
        syntax = File.join(Uv.syntax_path, "#{language}.syntax")
        Textpow::SyntaxNode.load(syntax) if File.exist?(syntax)
      end
    end
  end
end
