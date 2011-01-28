module Ruco
  class History
    def initialize(options)
      @options = options
      @stack = [@options.delete(:state)]
      @position = 0
    end

    def state
      @stack[@position]
    end

    def add(state)
      return unless tracked_field_changes?(state)
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

    private

    def tracked_field_changes?(data)
      @options[:track].any? do |field|
        state[field] != data[field]
      end
    end
  end
end