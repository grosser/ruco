module Ruco
  class History
    def initialize(options)
      @stack = [options[:state]]
      @position = 0
    end

    def state
      @stack[@position]
    end

    def add(state)
      @position += 1
      @stack.slice!(@position, 9999999) # remove all old stuff
      @stack << state
    end

    def undo
      @position = [@position - 1, 0].max
    end

    def redo
      @position = [@position + 1, @stack.size - 1].min
    end
  end
end