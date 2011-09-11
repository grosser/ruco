module Ruco
  module SyntaxParser
    def self.parse_lines(lines, language)
      setup
      syntax = File.join(Uv.path.first, 'uv', 'syntax', "#{language}.syntax")
      if syntax = Textpow::SyntaxNode.load(syntax)
        processor = syntax.parse(lines.join("\n"),  Ruco::ArrayProcessor.new)
        processor.lines
      else
        []
      end
    end

    def self.setup
      @@setup ||= begin
        require 'ultra_pow_list'
        require 'ruco/array_processor'
        UltraPowList.make_loadable
        require 'textpow'
        require 'uv'
      end
    end
  end
end
