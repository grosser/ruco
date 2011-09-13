module Ruco
  module SyntaxParser
    def self.parse_lines(lines, language)
      syntax = File.join(Uv.syntax_path, "#{language}.syntax")
      if syntax = Textpow::SyntaxNode.load(syntax)
        processor = syntax.parse(lines.join("\n"),  Ruco::ArrayProcessor.new)
        processor.lines
      else
        []
      end
    end
  end
end
