module Ruco
  class TextArea
    SURROUNDING_CHARS = {
      '<' => '>',
      '(' => ')',
      '[' => ']',
      '{' => '}',
      '"' => '"',
      "'" => "'",
      "`" => "`",
      '/' => '/'
    }

    attr_reader :lines, :selection, :column, :line

    def initialize(content, options)
      @lines = content.naive_split("\n")
      @options = options.dup
      @column = 0
      @line = 0
      @window = Window.new(@options.delete(:lines), @options.delete(:columns), @options[:window]||{})
      adjust_window
    end

    def view
      adjust_window
      @window.crop(lines) * "\n"
    end

    def cursor
      adjust_window
      @window.cursor
    end

    def style_map
      adjust_window
      @window.style_map(@selection)
    end

    def move(where, *args)
      case where
      when :relative
        move_relative(*args)
      when :to
        self.line, self.column = args
      when :to_bol then move_to_bol(*args)
      when :to_eol then move_to_eol(*args)
      when :to_line then self.line = args.first
      when :to_column then self.column = args.first
      when :to_index then move(:to, *position_for_index(*args))
      when :page_down
        self.line += @window.lines
        @window.set_top(@window.top + @window.lines, @lines.size)
      when :page_up
        self.line -= @window.lines
        @window.set_top(@window.top - @window.lines, @lines.size)
      when :jump
        move_jump(args.first)
      else
        raise "Unknown move type #{where} with #{args.inspect}"
      end
      @selection = nil unless @selecting
    end

    def selecting(&block)
      start = if @selection
        (position == @selection.first ? @selection.last : @selection.first)
      else
        position
      end

      @selecting = true
      instance_exec(&block)
      @selecting = false

      sorted = [start, position].sort
      @selection = sorted[0]..sorted[1]
    end

    def text_in_selection
      return '' unless @selection
      start = index_for_position(@selection.first)
      finish = index_for_position(@selection.last)
      content.slice(start, finish-start)
    end

    def reset
      @selection = nil
    end

    def insert(text)
      if @selection
        if SURROUNDING_CHARS[text]
          return surround_selection_with(text)
        else
          delete_content_in_selection
        end
      end

      text.tabs_to_spaces!
      if text == "\n" and @column >= current_line.leading_whitespace.size
        current_whitespace = current_line.leading_whitespace
        next_whitespace = lines[line+1].to_s.leading_whitespace
        text = text + [current_whitespace, next_whitespace].max
      end
      insert_into_content text
      move_according_to_insert text
    end

    def delete(count)
      if @selection
        delete_content_in_selection
        return
      end

      if count > 0
        if current_line[@column..-1].size >= count
          current_line.slice!(@column, count)
        else
          with_lines_as_string do |content|
            content.slice!(index_for_position, count)
          end
        end
      else
        backspace(count.abs)
      end
    end

    def index_for_position(position=self.position)
      lines[0...position.line].sum{|l| l.size + 1} + position.column
    end

    def content
      (lines * "\n").freeze
    end

    def resize(lines, columns)
      @window.lines = lines
      @window.columns = columns
    end

    def position
      Position.new(line, column)
    end

    protected

    def position_for_index(index)
      jump = content.slice(0, index).to_s.naive_split("\n")
      [jump.size - 1, jump.last.size]
    end

    def with_lines_as_string
      string = @lines * "\n"
      yield string
      @lines = string.naive_split("\n")
    end

    def after_last_word
      current_line.index(/\s*$/)
    end

    def move_to_eol
      after_last_whitespace = current_line.size

      if @column == after_last_whitespace or @column < after_last_word
        move :to_column, after_last_word
      else
        move :to_column, after_last_whitespace
      end
    end

    def move_to_bol
      before_first_word = current_line.index(/[^\s]/) || 0
      column = if @column == 0 or @column > before_first_word
        before_first_word
      else
        0
      end
      move :to_column, column
    end

    def move_relative(line_change, column_change)
      if line_change == 0
        # let user wrap around start/end of line
        move :to_index, index_for_position + column_change
      else
        # normal movement
        self.line += line_change
        self.column += column_change
      end
    end

    def move_jump(direction)
      regex = /\b/m
      text = content

      next_index = if direction == :right
        text.index(regex, index_for_position + 1) || text.size
      else
        text.rindex(regex,[index_for_position - 1, 0].max) || 0
      end

      move :to_index, next_index
    end

    def backspace(count)
      if @column >= count
        new_colum = @column - count
        current_line.slice!(new_colum, count)
        move :to_column, new_colum
      else
        start_index = index_for_position - count
        if start_index < 0
          count += start_index
          start_index = 0
        end

        with_lines_as_string do |content|
          content.slice!(start_index, count)
        end

        move :to, *position_for_index(start_index)
      end
    end

    def line=(x)
      @line = [[x, 0].max, [lines.size - 1, 0].max ].min
      self.column = @column # e.g. now in an empty line
    end

    def column=(x)
      @column = [[x, 0].max, current_line.size].min
    end

    def position=(pos)
      self.line, self.column = pos
    end

    def insert_into_content(text)
      if text.include?("\n")
        with_lines_as_string do |content|
          content.insert(index_for_position, text)
        end
      else
        # faster but complicated for newlines
        lines[line] ||= ''
        lines[line].insert(@column, text)
      end
    end

    def position_inside_content?
      line < lines.size and @column < lines[line].to_s.size
    end

    def current_line
      lines[line] || ''
    end

    def move_according_to_insert(text)
      inserted_lines = text.naive_split("\n")
      if inserted_lines.size > 1
        self.line += inserted_lines.size - 1
        self.column = inserted_lines.last.size
      else
        move(:relative, inserted_lines.size - 1, inserted_lines.last.size)
      end
    end

    def delete_content_in_selection
      with_lines_as_string do |content|
        start = index_for_position(@selection.first)
        finish = index_for_position(@selection.last)
        content.slice!(start, finish-start)
        move(:to, *@selection.first)
      end
      @selection = nil
    end

    def sanitize_position
      self.line = line
      self.column = column
    end

    def adjust_window
      sanitize_position
      @window.set_position(position, :max_lines => @lines.size)
    end

    def surround_selection_with(text)
      open_char = text
      close_char = SURROUNDING_CHARS[text]
      old_selection = @selection.deep_copy
      selected = text_in_selection

      replace_surrounding_chars = SURROUNDING_CHARS.any?{|chars| selected.surrounded_in?(*chars) }
      if replace_surrounding_chars
        selected = selected[1..-2]
      else
        old_selection.last.column += (selected.include?("\n") ? 1 : 2)
      end

      insert("#{open_char}#{selected}#{close_char}")
      @selection = old_selection
    end
  end
end
