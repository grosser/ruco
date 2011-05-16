module Ruco
  class History
    attr_accessor :timeout
    attr_reader :stack, :position

    def initialize(options)
      @options = options
      @options[:entries] ||= 100
      @timeout = options.delete(:timeout) || 0
      
      @stack = [{:mutable => false, :created_at => 0, :type => :initial, :state => @options.delete(:state)}]
      @position = 0
    end

    def state
      @stack[@position][:state]
    end

    def add(state)
      return unless tracked_field_changes?(state)
      remove_undone_states
      unless merge? state
        # can no longer modify previous states
        @stack[@position][:mutable] = false
        
        state_type = type(state)
        @position += 1
        @stack[@position] = {:mutable => true, :type => state_type, :created_at => Time.now.to_f}
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
    def type(state)
      @options[:track].each do |field|
        if state[field].is_a?(String) && @stack[@position][:state][field].is_a?(String)
          diff = state[field].length - @stack[@position][:state][field].length
          if diff > 0
            return :insert
          elsif diff < 0
            return :delete
          end
        end
      end
      nil
    end
    
    def merge?(state)
      top = @stack[@position]
      #puts
      #puts @stack.inspect
      #puts [state, type(state), top, top[:mutable] && top[:type] == type(state) && top[:created_at]+@timeout > Time.now.to_f].inspect
      top[:mutable] &&
        top[:type] == type(state) &&
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
      return if @options[:entries] == 0
      to_remove = @stack.size - @options[:entries]
      return if to_remove < 1
      @stack.slice!(0, to_remove)
      @position -= to_remove
    end
  end
end