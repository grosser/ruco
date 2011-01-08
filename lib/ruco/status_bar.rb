module Ruco
  class StatusBar
    def initialize(editor, options)
      @editor = editor
      @options = options
    end

    def view
      "Ruco #{Ruco::VERSION} -- #{@editor.file}#{change_indicator}"
    end

    def format
      Curses::A_REVERSE
    end

    def change_indicator
      @editor.modified? ? '*' : ' '
    end
  end
end