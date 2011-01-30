module Ruco
  class Window
    OFFSET = 5

    attr_accessor :position, :lines, :columns
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

    def color_mask(selection)
      mask = Array.new(lines)
      return mask unless selection

      mask.map_with_index do |_,line|
        visible = visible_area(line)
        next unless selection.overlap?(visible)

        first = [selection.first, visible.first].max
        last = [selection.last, visible.last].min

        [
          [first[1]-left, Curses::A_REVERSE],
          [last[1]-left, Curses::A_NORMAL]
        ]
      end
    end

    private

    def visible_area(line)
      line += @top
      start_of_line = [line, @left]
      last_visible_column = @left + @columns
      end_of_line = [line, last_visible_column]
      start_of_line..end_of_line
    end

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