module Ruco
  class Editor
    attr_reader :cursor_line, :cursor_column

    def initialize(file, options)
      @file = file
      @options = options
      @lines = File.read(@file).split("\n")
      @line = 0
      @column = 0
      @cursor_line = 0
      @cursor_column = 0
      @scrolled_lines = 0
      @scrolled_columns = 0
    end

    def view
      Array.new(@options[:lines]).map_with_index do |_,i|
        (@lines[i + @scrolled_lines] || "").slice(@scrolled_columns, @options[:columns])
      end * "\n" + "\n"
    end

    def move(line, column)
      @line =    [[@line   + line,    0].max, @lines.size].min
      @column =  [[@column + column, 0].max, (@lines[@line]||'').size].min

      @cursor_line = @line - @scrolled_lines
      @cursor_column = @column - @scrolled_columns

#      if @cursor_line >= @options[:lines]
#        @scrolled_lines += 5
#        @cursor_line -= 5
#      end

      if @cursor_column >= @options[:columns]
        @scrolled_columns += 5
        @cursor_column -= 5
      end
    end
  end
end