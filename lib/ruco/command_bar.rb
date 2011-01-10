module Ruco
  class CommandBar
    include Focusable

    attr_accessor :cursor_line, :find_form
    delegate :move, :to => :find_form

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
      if @find_form
        @find_form.view
      else
        available_shortcuts
      end
    end

    def find
      @find_form ||= Form.new('Find: ', :columns => @options[:columns])
    end

    def insert(text)
      result = @find_form.insert(text)
      Command.new(:find, result) if result
    end

    def reset
      @find_form = nil
    end

    def cursor_column
      if @find_form
        @find_form.cursor[1]
      else
        0
      end
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