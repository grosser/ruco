module Ruco
  class CommandBar
    attr_accessor :cursor_line, :form
    delegate :move, :delete, :insert, :selecting, :selection, :text_in_selection, :to => :form

    SHORTCUTS = [
      '^W Exit',
      '^S Save',
      '^F Find',
      '^R Replace',
      '^D Delete line',
      '^G Go to line',
      '^B Select mode'
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

    def ask(question, options={}, &block)
      @form = cached_form_if(options[:cache], question) do
        Form.new(question, :columns => @options[:columns]) do |result|
          @form = nil
          block.call(result)
        end
      end
    end

    def reset
      @forms_cache[@forms_cache.key(@form)] = nil
      @form = nil
    end

    def cursor
      if @form
        Position.new cursor_line, @form.cursor.column
      else
        Position.new cursor_line, 0
      end
    end

    private

    def cached_form_if(cache, question)
      if cache
        new_form = yield
        new_form.insert(@forms_cache[question].value) if @forms_cache[question]
        @forms_cache[question] = new_form
      else
        yield
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
