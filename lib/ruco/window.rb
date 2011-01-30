module Ruco
  class Window
    OFFSET = 5

    attr_writer :position
    attr_reader :top, :left

    def initialize(lines, columns)
      @lines = lines
      @columns = columns
      @top = 0
      @left = 0
    end

    def crop(content)
      lines = content.slice(0, @lines)
      lines[@lines-1] ||= nil
      lines.map do |line|
        line ||= ''
        line.slice!(@columns, 99999) # drop everything we dont need
        line + (' ' * (@columns - line.size))
      end
    end

    def position=(pos)
      @top = pos.line - OFFSET unless visible_lines.include?(pos.line)
      @left = pos.column - OFFSET  unless visible_columns.include?(pos.column)
    end

    private

    def visible_lines
      @top..(@top+@lines-1)
    end

    def visible_columns
      @left..(@left+@columns-1)
    end
  end
end