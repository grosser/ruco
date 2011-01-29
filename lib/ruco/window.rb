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
      scroll_line_into_view position.line, (options[:max_lines] || 9999)
      scroll_column_into_view position.column
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

    def scroll_line_into_view(line, total_lines)
      result = adjustment(line, visible_lines, @options[:line_scroll_threshold], @options[:line_scroll_offset])
      set_top result, total_lines if result
    end

    def scroll_column_into_view(column)
      result = adjustment(column, visible_columns, @options[:column_scroll_threshold], @options[:column_scroll_offset])
      self.left = result if result
    end

    def color_mask(selection)
      mask = StyleMap.new(lines)
      return mask unless selection

      lines.times do |line|
        visible = visible_area(line)
        next unless selection.overlap?(visible)

        first = [selection.first, visible.first].max
        first = first[1] - left
        last = [selection.last, visible.last].min
        last = last[1] - left

        mask.add(:reverse, line, first...last)
      end

      mask
    end

    def left=(x)
      @left = [x,0].max
    end

    def set_top(line, total_lines)
      max_top = total_lines - lines + 1 + @options[:line_scroll_offset]
      @top = [[line, max_top].min, 0].max
    end

    private

    def adjustment(current, allowed, threshold, offset)
      if current < (allowed.first + threshold)
        current - offset
      elsif current > (allowed.last - threshold)
        size = allowed.last - allowed.first + 1
        current - size + 1 + offset
      end
    end

    def visible_area(line)
      line += @top
      start_of_line = [line, @left]
      last_visible_column = @left + @columns
      end_of_line = [line, last_visible_column]
      start_of_line..end_of_line
    end

    def visible_lines
      @top..(@top+@lines-1)
    end

    def visible_columns
      @left..(@left+@columns-1)
    end
  end
end