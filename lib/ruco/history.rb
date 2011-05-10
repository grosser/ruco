module Ruco
  class History
    attr_accessor :timeout

    def initialize(options)
      @options = options
      @stack = [@options.delete(:state)]
      @timeout = options.delete(:timeout) || 0
      timeout!
      @position = 0
    end

    def state
      @stack[@position]
    end

    def add(state)
      return unless tracked_field_changes?(state)
      remove_undone_states
      if merge_timeout?
        @position += 1
        @last_merge = Time.now.to_f
      end
      @stack[@position] = state
      limit_stack
    end

    def undo
      timeout!
      @position = [@position - 1, 0].max
    end

    def redo
      timeout!
      @position = [@position + 1, @stack.size - 1].min
    end

    private

    def remove_undone_states
      @stack.slice!(@position + 1, 9999999)
    end

    def tracked_field_changes?(data)
      @options[:track].any? do |field|
        state[field] != data[field]
      end
    end

    def limit_stack
      to_remove = @stack.size - @options[:entries]
      return if to_remove < 1
      @stack.slice!(0, to_remove)
      @position -= to_remove
    end

    def timeout!
      @last_merge = 0
    end

    def merge_timeout?
      (Time.now.to_f - @last_merge) > @timeout
    end
  end
end
