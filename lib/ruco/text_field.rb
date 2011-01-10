module Ruco
  class TextField
    def initialize(options)
      @options = options
      @content = ''
      @column = 0
    end

    def insert(text)
      @content += text
      move(0, text.size)
    end

    def view
      @content
    end

    def value
      @content
    end

    def move(line, column)
      @column += column
    end

    def cursor
      [0, @column]
    end
  end
end