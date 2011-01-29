module Ruco
  class StyleMap
    attr_accessor :lines

    def initialize(lines)
      @lines = Array.new(lines)
    end

    def add(style, line, columns)
      @lines[line] ||= []
      @lines[line] << [style, columns]
    end

    def flatten
      @lines.map do |styles|
        next unless styles
        flat = []

        # add style info to every column
        styles.each do |style, columns|
          columns.to_a.each do |column|
            flat[column] ||= []
            flat[column].unshift style
          end
        end

        flat << [] # reset styles after last
        flat
      end
    end

    def +(other)
      lines = self.lines + other.lines
      new = StyleMap.new(0)
      new.lines = lines
      new
    end

    def slice!(*args)
      sliced = lines.slice!(*args)
      new = StyleMap.new(0)
      new.lines = sliced
      new
    end

    def shift
      slice!(0, 1)
    end

    def pop
      slice!(-1, 1)
    end
  end
end