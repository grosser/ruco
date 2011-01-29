module Ruco
  class StyleMap
    def initialize(lines)
      @lines = Array.new(lines).fill{[]}
    end

    def add(style, line, columns)
      @lines[line] << [style, columns]
    end

    def flatten
      @lines.map do |styles|
        next if styles.empty?
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
  end
end