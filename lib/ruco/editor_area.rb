module Ruco
  # everything that does not belong to a text-area
  # but is needed for Ruco::Editor
  class EditorArea < TextArea
    LINE_NUMBERS_SPACE = 5

    def initialize(content, options)
      options[:columns] -= LINE_NUMBERS_SPACE if options[:line_numbers]
      super(content, options)
      @history = History.new((options[:history]||{}).reverse_merge(:state => state, :track => [:content], :entries => 100, :timeout => 2))
    end

    def undo
      @history.undo
      self.state = @history.state
    end

    def redo
      @history.redo
      self.state = @history.state
    end

    def view
      @history.add(state)
      if @options[:line_numbers]
        number_room = LINE_NUMBERS_SPACE - 1

        super.naive_split("\n").map_with_index do |line,i|
          number = @window.top + i
          number = if lines[number]
            (number + 1).to_s
                   else
                     ''
                   end.rjust(number_room).slice(0,number_room)
          "#{number} #{line}"
        end * "\n"
      else
        super
      end
    end

    def style_map
      if @options[:line_numbers]
        map = super
        map.left_pad!(LINE_NUMBERS_SPACE)
        map
      else
        super
      end
    end

    def cursor
      if @options[:line_numbers]
        cursor = super
        cursor[1] += LINE_NUMBERS_SPACE
        cursor
      else
        super
      end
    end

    def delete_line
      lines.slice!(line, 1)
      sanitize_position
    end

    def move_line(direction)
      old = line
      new = line + direction
      return if new < 0
      return if new >= lines.size
      lines[old].leading_whitespace = lines[new].leading_whitespace
      lines[old], lines[new] = lines[new], lines[old]
      @line += direction
    end

    def indent
      selected_lines.each do |line|
        lines[line].insert(0, ' ' * Ruco::TAB_SIZE)
      end
      adjust_to_indentation Ruco::TAB_SIZE
    end

    def unindent
      lines_to_unindent = (selection ? selected_lines : [line])
      removed = lines_to_unindent.map do |line|
        remove = [lines[line].leading_whitespace.size, Ruco::TAB_SIZE].min
        lines[line].slice!(0, remove)
        remove
      end

      adjust_to_indentation -removed.first, -removed.last
    end

    def state
      {
        :content => content,
        :position => position,
        :screen_position => screen_position
      }
    end

    def state=(data)
      @selection = nil
      @lines = data[:content].naive_split("\n") if data[:content]
      self.position = data[:position]
      self.screen_position = data[:screen_position]
    end

    private

    # TODO use this instead of instance variables
    def screen_position
      Position.new(@window.top, @window.left)
    end

    def screen_position=(pos)
      @window.set_top(pos[0], @lines.size)
      @window.left = pos[1]
    end

    def adjust_to_indentation(first, last=nil)
      last ||= first
      if selection
        cursor_adjustment = (selection.first == position ? first : last)
        selection.first.column = [selection.first.column + first, 0].max
        selection.last.column = [selection.last.column + last, 0].max
        self.column += cursor_adjustment
      else
        self.column += first
      end
    end

    def selected_lines
      selection.first.line.upto(selection.last.line)
    end
  end
end
