module Ruco
  class ArrayProcessor
    attr_accessor :lines

    def initialize
      @line_number = -1
      @lines = []
      @open_positions = []
    end

    def open_tag(name, position)
      @open_positions << position
    end

    def close_tag(name, position)
      @lines[@line_number] << [name.to_sym, @open_positions.pop...position]
    end

    def new_line(line)
      @line_number += 1
      @lines[@line_number] = []
    end

    def start_parsing(name);end
    def end_parsing(name);end

    def inspect
      @lines
    end
  end
end
