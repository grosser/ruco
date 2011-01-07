module Ruco
  class Editor
    attr_reader :line, :column

    def initialize(file, options)
      @file = file
      @options = options
      @lines = File.read(@file).split("\n")
      @line = 0
      @column = 0
    end

    def view
      Array.new(@options[:lines]).map_with_index do |_,i|
        (@lines[i] || "").slice(0, @options[:columns])
      end * "\n" + "\n"
    end

    def move(line, column)
      @line =    [[@line   + line,    0].max, @lines.size].min
      @column =  [[@column + column, 0].max, (@lines[@line]||'').size].min
    end
  end
end