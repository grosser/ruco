module Ruco
  class CommandBar
    SHORTCUTS = [
      '^W Exit',
      '^S Save',
      '^F Find',
      '^D Delete line'
    ]

    def initialize(editor, options)
      @editor = editor
      @options = options
    end

    def view
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