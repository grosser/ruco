module Ruco
  class Editor
    module History
      def initialize(content, options)
        super(content, options)
        @history = Ruco::History.new((options[:history]||{}).reverse_merge(:state => state, :track => [:content], :entries => 100, :timeout => 2))
      end

      def undo
        @history.undo
        self.state = @history.state
      end

      def redo
        @history.redo
        self.state = @history.state
      end

      def view
        @history.add(state)
        super
      end
    end
  end
end
