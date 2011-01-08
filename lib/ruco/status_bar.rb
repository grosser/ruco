module Ruco
  class StatusBar
    def initialize(editor, options)
      @editor = editor
      @options = options
    end

    def view
      "Ruco #{Ruco::VERSION}"
    end
  end
end