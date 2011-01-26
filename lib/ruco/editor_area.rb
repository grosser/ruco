module Ruco
  # everything that does not belong to a text-area
  # but is needed for Ruco::Editor
  class EditorArea < TextArea
    def delete_line
      lines.slice!(@line, 1)
      adjust_view
    end

    def indent
      selected_lines.each do |line|
        @lines[line].insert(0, ' ' * Ruco::TAB_SIZE)
      end
      adjust_to_indentation Ruco::TAB_SIZE
      adjust_view
    end

    def unindent
      lines_to_unindent = (selection ? selected_lines : [@line])
      removed = lines_to_unindent.map do |line|
        remove = [@lines[line].leading_whitespace.size, Ruco::TAB_SIZE].min
        @lines[line].slice!(0, remove)
        remove
      end

      adjust_to_indentation -removed.first, -removed.last
      adjust_view
    end

    private

    def adjust_to_indentation(first, last=nil)
      last ||= first
      if selection
        cursor_adjustment = (selection.first == position ? first : last)
        selection.first.column = [selection.first.column + first, 0].max
        selection.last.column = [selection.last.column + last, 0].max
        @column += cursor_adjustment
      else
        @column += first
      end
    end

    def selected_lines
      selection.first.line.upto(selection.last.line)
    end
  end
end