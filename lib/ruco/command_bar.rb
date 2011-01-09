module Ruco
  class CommandBar
    include Focusable

    attr_accessor :cursor_line

    SHORTCUTS = [
      '^W Exit',
      '^S Save',
      '^F Find',
      '^D Delete line'
    ]

    SEARCH_PREFIX = "Find: "

    def initialize(options)
      @options = options
      reset
    end

    def view
      if @find_mode
        SEARCH_PREFIX + @find_term
      else
        available_shortcuts
      end
    end

    def find
      @find_mode = true
    end

    def insert(text)
      @find_term += text
      if @find_term.include?("\n")
        @find_term.gsub!("\n",'')

        @find_offset = find_offset(@find_term)
        @find_last = @find_term
        Command.new(:find, @find_term, :offset => @find_offset)
      end
    end

    def reset
      @find_mode = false
      @find_offset = 0
      @find_term = ''
      @find_last = nil
    end

    def cursor_column
      view.size
    end

    private

    def find_offset(term)
      if term == @find_last
        @find_offset + 1
      else
        0
      end
    end

    def available_shortcuts
      used_columns = 0
      spacer = '    '
      shortcuts_that_fit = SHORTCUTS.select do |shortcut|
        used_columns += shortcut.size
        it_fits = (used_columns <= @options[:columns])
        used_columns += spacer.size
        it_fits
      end
      shortcuts_that_fit * spacer
    end
  end
end