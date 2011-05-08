module Ruco
  class StatusBar
    def initialize(editor, options)
      @editor = editor
      @options = options
    end

    def view
      position = @editor.position
      spread "Ruco #{Ruco::VERSION} -- #{@editor.file}#{change_indicator}#{writable_indicator}", "#{position.line + 1}:#{position.column + 1}"
    end

    def change_indicator
      @editor.modified? ? '*' : ' '
    end

    def writable_indicator
      @writable ||= begin
        writable = (not File.exist?(@editor.file) or system("test -w #{@editor.file}"))
        writable ? ' ' : '!'
      end
    end

    private

    def spread(left, right)
      empty = [@options[:columns] - left.size - right.size, 0].max
      "#{left}#{' ' * empty}#{right}"
    end
  end
end
