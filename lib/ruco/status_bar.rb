module Ruco
  class StatusBar
    def initialize(editor, options)
      @editor = editor
      @options = options
    end

    def view
      columns = @options[:columns]

      version = "Ruco #{Ruco::VERSION} -- "
      position = " #{@editor.position.line + 1}:#{@editor.position.column + 1}"
      indicators = "#{change_indicator}#{writable_indicator}"
      essential = version + position + indicators
      space_left = [columns - essential.size, 0].max

      # fit file name into remaining space
      file = @editor.file
      file = file.ellipsize(:max => space_left)
      space_left -= file.size

      "#{version}#{file}#{indicators}#{' ' * space_left}#{position}"[0, columns]
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
