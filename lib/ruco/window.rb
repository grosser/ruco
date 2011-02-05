module Ruco
  class Window
    OFFSET = 5

    attr_accessor :lines, :columns, :left
    attr_reader :cursor, :top

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

    def position=(x)
      set_position(x)
    end

    def set_position(position, options={})
      adjust_top(position.line, options[:max_lines] || 9999)
      adjust_left(position.column)
      @cursor = Position.new(position.line - @top, position.column - @left)
    end

    def crop(lines)
      lines_to_display = lines[visible_lines] || []
      lines_to_display[@lines-1] ||= nil
      lines_to_display.map do |line|
        line ||= ''
        line[visible_columns] || ''
      end
    end

    def scroll_lines(amount, max)
      set_top(@top + amount, max)
    end

    def adjust_top(line, max)
      if line < (visible_lines.first + @options[:line_scroll_threshold])
        set_top line - @options[:line_scroll_offset], max
      elsif line > (visible_lines.last - @options[:line_scroll_threshold])
        top = line - lines + 1 + @options[:line_scroll_offset]
        set_top top, max
      end
    end

    def adjust_left(column)
      if column < visible_columns.first + @options[:column_scroll_threshold]
        self.left = column - @options[:column_scroll_offset]
      elsif column > visible_columns.last - @options[:column_scroll_threshold]
        self.left = column - columns + 1 + @options[:column_scroll_offset]
      end
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

    def left=(x)
      @left = [x,0].max
    end

    def set_top(line, max)
      max_top = max - lines + 1 + @options[:line_scroll_offset]
      @top = [[line, max_top].min, 0].max
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