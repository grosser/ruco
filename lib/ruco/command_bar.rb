module Ruco
  class CommandBar
    include Focusable

    attr_accessor :cursor_line, :form
    delegate :move, :delete, :insert, :to => :form

    SHORTCUTS = [
      '^W Exit',
      '^S Save',
      '^F Find',
      '^D Delete line',
      '^G Go to line'
    ]

    SEARCH_PREFIX = "Find: "

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
      @form = @forms_cache[:find] ||= Form.new('Find: ', :columns => @options[:columns], :command => :find)
    end

    def move_to_line
      @form = Form.new('Go to Line: ', :columns => @options[:columns], :command => :move_to_line, :type => :integer)
    end

    def reset
      @forms_cache[:find] = nil if @form == @forms_cache[:find]
      @form = nil
    end

    def cursor_column
      if @form
        @form.cursor[1]
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