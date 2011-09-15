module Ruco
  class ArrayProcessor
    attr_accessor :lines

    def initialize
      @line_number = -1
      @lines = []
      @open_elements = []
      @still_open_elements = []
    end

    def open_tag(name, position)
      #puts "Open #{name}  #{@line_number}:#{position}"
      @open_elements << [name, position]
    end

    def close_tag(name, position)
      #puts "Close #{name} #{@line_number}:#{position}"
      open_element = @open_elements.pop || @still_open_elements.pop
      @lines[@line_number] << [name, open_element.last...position]
    end

    def new_line(line)
      #puts "Line #{line}"
      # close elements only opened in last line
      @open_elements.each do |name, position|
        @lines[@line_number] << [name, position...@line.size]
      end

      # surround last line in still open elements from previouse lines
      @still_open_elements.each do |name,_|
        @lines[@line_number] << [name, 0...@line.size]
      end

      # mark open as 'still open'
      # and let them start on column 0 -> if closed in this line its 0...position
      @still_open_elements += @open_elements.map{|name,_| [name,0]}
      @open_elements = []

      # proceed with next line
      @line = line
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
