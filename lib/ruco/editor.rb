module Ruco
  class Editor
    include Focusable

    SCROLLING_OFFSET = 20

    attr_reader :cursor_line, :cursor_column, :file

    def initialize(file, options)
      @file = file
      @options = options
      @content = tabs_to_spaces((File.exist?(@file) ? File.read(@file) : ''))
      @line = 0
      @column = 0
      @cursor_line = 0
      @cursor_column = 0
      @scrolled_lines = 0
      @scrolled_columns = 0
      @modified = false
      @options[:line_scrolling_offset] ||= @options[:lines] / 2
      @options[:column_scrolling_offset] ||= @options[:columns] / 2
    end

    def view
      Array.new(@options[:lines]).map_with_index do |_,i|
        (lines[i + @scrolled_lines] || "").slice(@scrolled_columns, @options[:columns])
      end * "\n" + "\n"
    end

    def move(line, column)
      @line =    [[@line   + line,    0].max, lines.size].min
      @column =  [[@column + column, 0].max, (lines[@line]||'').size].min
      adjust_view
    end

    def move_to(line, column)
      @line = line
      @column = column
      adjust_view
    end

    def move_to_line(line)
      move_to(line, @column)
    end

    def move_to_column(column)
      move_to(@line, column)
    end

    def move_to_eol
      after_last_word = current_line.index(/\s*$/)
      after_last_whitespace = current_line.size

      if @column == after_last_whitespace or @column < after_last_word
        move_to_column after_last_word
      else
        move_to_column after_last_whitespace
      end
    end

    def move_to_bol
      before_first_word = current_line.index(/[^\s]/) || 0
      if @column == 0 or @column > before_first_word
        move_to_column before_first_word
      else
        move_to_column 0
      end
    end

    def find(text)
      index = @content.index(text, cursor_index+1) || cursor_index
      move_to *cursor_for_index(index)
    end

    def insert(text)
      text = tabs_to_spaces(text)
      insert_into_content cursor_index, text
      move_according_to_insert(text)
      @modified = true
    end

    def delete(count)
      if count > 0
        @content.slice!(cursor_index, count)
      else
        backspace(count.abs)
      end
      @modified = true
    end

    def backspace(count)
      start_index = cursor_index - count
      if start_index < 0
        count += start_index
        start_index = 0
      end

      @content.slice!(start_index, count)
      move_to *cursor_for_index(start_index)
      @modified = true
    end

    def save
      File.open(@file,'w'){|f| f.write(@content) }
      @modified = false
    end

    def cursor
      [cursor_line, cursor_column]
    end

    def modified?
      @modified
    end

    private

    def lines
      @content.naive_split("\n")
    end

    def adjust_view
      reposition_cursor
      scroll_column_into_view
      scroll_line_into_view
      reposition_cursor
    end

    def scroll_column_into_view
      offset = [@options[:column_scrolling_offset], @options[:columns]].min

      if @cursor_column >= @options[:columns]
        @scrolled_columns = @column - @options[:columns] + offset
      end

      if @cursor_column < 0
        @scrolled_columns = @column - offset
      end

      @scrolled_columns = [[@scrolled_columns, 0].max, @column].min
    end

    def scroll_line_into_view
      offset = [@options[:line_scrolling_offset], @options[:lines]].min

      if @cursor_line >= @options[:lines]
        @scrolled_lines = @line - @options[:lines] + offset
      end

      if @cursor_line < 0
        @scrolled_lines = @line - offset
      end

      @scrolled_lines = [[@scrolled_lines, 0].max, @line].min
    end

    def reposition_cursor
      @cursor_column = @column - @scrolled_columns
      @cursor_line = @line - @scrolled_lines
    end

    def insert_into_content(index, text)
      # expand with newlines when inserting after maximum position
      if index > @content.size
        @content << "\n" * (index - @content.size)
      end
      @content.insert(index, text)
    end

    def current_line
      lines[@line] || ''
    end

    def cursor_index
      index = lines[0...@line].join("\n").size + @column
      index += 1 if @line > 0 # account for missing newline
      index
    end

    def cursor_for_index(index)
      jump = @content.slice(0, index).to_s.naive_split("\n")
      [jump.size - 1, jump.last.size]
    end

    def move_according_to_insert(text)
      inserted_lines = text.naive_split("\n")
      if inserted_lines.size > 1
        # column position does not add up when hitting return
        @column = inserted_lines.last.size
        move(inserted_lines.size - 1, 0)
      else
        move(inserted_lines.size - 1, inserted_lines.last.size)
      end
    end

    def tabs_to_spaces(text)
      text.gsub("\t",' ' * Ruco::TAB_SIZE)
    end
  end
end