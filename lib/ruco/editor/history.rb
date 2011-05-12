module Ruco
  class Editor
    module History
      attr_reader :history
      
      def initialize(content, options)
        super(content, options)
        @history = Ruco::History.new((options[:history]||{}).reverse_merge(:state => state, :track => [:content], :entries => options[:undo_stack_size], :timeout => 2))
      end

      def undo
        @history.undo
        self.state = @history.state
      end

      def redo
        @history.redo
        self.state = @history.state
      end
      
      def save_state(type)
        @history.add(type, state)
      end
    end
  end
end
