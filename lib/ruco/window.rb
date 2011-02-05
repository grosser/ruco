module Ruco
  class Window
    OFFSET = 5

    attr_accessor :position, :lines, :columns, :top, :left
    attr_reader :cursor

    def initialize(lines, columns, options={})
      @options = options

      @options[:line_scroll_threshold] ||= 1
      @options[:line_scroll_offset] ||= 1
      @options[:column_scroll_threshold] ||= 1
      @options[:column_scroll_offset] ||= 5

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
        line[visible_columns] || ''
      end
    end

    def position=(pos)
      if pos.line < visible_lines.first + @options[:line_scroll_threshold]
        self.top = pos.line - @options[:line_scroll_offset]
      elsif pos.line > visible_lines.last - @options[:line_scroll_threshold]
        self.top = pos.line - lines + 1 + @options[:line_scroll_offset]
      end

      if pos.column < visible_columns.first + @options[:column_scroll_threshold]
        self.left = pos.column - @options[:column_scroll_offset]
      elsif pos.column > visible_columns.last - @options[:column_scroll_threshold]
        self.left = pos.column - columns + 1 + @options[:column_scroll_offset]
      end

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

    def top=(x)
      @top = [x,0].max
    end

    def left=(x)
      @left = [x,0].max
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