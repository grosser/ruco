module Ruco
  class Window
    OFFSET = 5

    attr_writer :position
    attr_reader :top, :left, :cursor

    def initialize(lines, columns)
      @lines = lines
      @columns = columns
      @top = 0
      @left = 0
      @cursor = Position.new(0,0)
    end

    def crop(content)
      lines = content[visible_lines] || []
      lines[@lines-1] ||= nil
      lines.map do |line|
        line ||= ''
        line = line[visible_columns] || ''
        whitespace = ' ' * (@columns - line.size)
        line << whitespace
      end
    end

    def position=(pos)
      @top = pos.line - line_offset unless visible_lines.include?(pos.line)
      @left = pos.column - column_offset  unless visible_columns.include?(pos.column)
      @cursor = Position.new(pos.line - @top, pos.column - @left)
    end

    private

    def line_offset
      @lines / 2
    end

    def column_offset
      @columns / 2
    end

    def visible_lines
      @top..(@top+@lines-1)
    end

    def visible_columns
      @left..(@left+@columns-1)
    end
  end
end