module Ruco
  class CommandBar
    attr_accessor :cursor_line, :form
    delegate :move, :delete, :insert, :to => :form

    SHORTCUTS = [
      '^W Exit',
      '^S Save',
      '^F Find',
      '^D Delete line',
      '^G Go to line'
    ]

    def initialize(options)
      @options = options
      @forms_cache = {}
      reset
    end

    def view
      if @form
        @form.view
      else
        available_shortcuts
      end
    end

    def find
      @forms_cache[:find] ||= Form.new('Find: ', :columns => @options[:columns]) do |value|
        Command.new(:find, value)
      end
      @form = @forms_cache[:find]
    end

    def move_to_line
      @form = Form.new('Go to Line: ', :columns => @options[:columns], :type => :integer) do |value|
        reset
        Command.new(:move, :to_line, value.to_i)
      end
    end

    def reset
      @forms_cache[:find] = nil if @form == @forms_cache[:find]
      @form = nil
    end

    def cursor
      if @form
        Cursor.new cursor_line, @form.cursor.column
      else
        Cursor.new cursor_line, 0
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