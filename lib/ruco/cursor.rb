module Ruco
  class Cursor < Array
    def initialize(line, column)
      super([line, column])
    end

    alias_method :line, :first
    alias_method :column, :last
  end
end