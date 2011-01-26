module Ruco
  class Position < Array
    def initialize(line, column)
      super([line, column])
    end

    def line=(x)
      self[0] = x
    end

    def column=(x)
      self[1] = x
    end

    alias_method :line, :first
    alias_method :column, :last
  end
end