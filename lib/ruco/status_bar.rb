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

    # fill the line with left column and then overwrite the right section
    def spread(left, right)
      empty = [@options[:columns] - left.size, 0].max
      line = left + (" " * empty)
      line[(@options[:columns] - right.size - 1)..-1] = ' ' + right
      line
    end
  end
end
