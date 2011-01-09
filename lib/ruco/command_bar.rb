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
        Command.new(:find, @find_term, :offset => 0)
      end
    end

    def reset
      @find_mode = false
      @find_term = ''
    end

    def cursor_column
      view.size
    end

    private

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