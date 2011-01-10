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

    def delete(count)
      if count > 0
        @content.slice!(@column, count)
      else
        delete_start = [@column - count.abs, 0].max
        @content[delete_start...@column] = ''
        @column = delete_start
      end
    end

    def view
      @content
    end

    def value
      @content
    end

    def move(line, column)
      @column = [[@column + column, 0].max, @content.size].min
    end

    def cursor
      [0, @column]
    end
  end
end