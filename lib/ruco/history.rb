module Ruco
  class History
    attr_accessor :timeout
    attr_reader :stack, :position

    def initialize(options)
      @options = options
      @timeout = options.delete(:timeout) || 0
      
      @stack = [{:mutable => false, :created_at => 0, :type => :initial, :state => @options.delete(:state)}]
      @position = 0
    end

    def state
      @stack[@position][:state]
    end

    # type should be a symbol denoting the type of event that triggered the modification
    # types of :insert and :delete will be merged with subsequent edits until either:
    #   @timeout seconds pass  or
    #   add is called with a different value for type
    def add(type, state)
      return unless tracked_field_changes?(state)
      remove_undone_states
      unless merge? type
        # can no longer modify previous states
        @stack[@position][:mutable] = false
        
        @position += 1
        @stack[@position] = {:mutable => (type == :insert || type == :delete), :created_at => Time.now.to_f, :type => type}
      end
      @stack[@position][:state] = state
      limit_stack
    end

    def undo
      @position = [@position - 1, 0].max
    end

    def redo
      @position = [@position + 1, @stack.size - 1].min
    end

    private
    def merge?(type)
      top = @stack[@position]
      top[:mutable] &&
        (type == :insert || type == :delete) &&
        type == top[:type] &&
        top[:created_at]+@timeout > Time.now.to_f
    end

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
  end
end