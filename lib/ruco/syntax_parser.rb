module Ruco
  module SyntaxParser
    def self.parse_lines(lines, language)
      if syntax = syntax_node(language)
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
        Textpow::SyntaxNode.load(syntax)
      end
    end
  end
end
