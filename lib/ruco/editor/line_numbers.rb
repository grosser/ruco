module Ruco
  class Editor
    module LineNumbers
      LINE_NUMBERS_SPACE = 5

      def initialize(content, options)
        options[:columns] -= LINE_NUMBERS_SPACE if options[:line_numbers]
        super(content, options)
      end

      def view
        if @options[:line_numbers]
          number_room = LINE_NUMBERS_SPACE - 1

          super.naive_split("\n").map_with_index do |line,i|
            number = @window.top + i
            number = if lines[number]
              (number + 1).to_s
                     else
                       ''
                     end.rjust(number_room).slice(0,number_room)
            "#{number} #{line}"
          end * "\n"
        else
          super
        end
      end

      def style_map
        if @options[:line_numbers]
          map = super
          map.left_pad!(LINE_NUMBERS_SPACE)
          map
        else
          super
        end
      end

      def cursor
        if @options[:line_numbers]
          cursor = super
          cursor[1] += LINE_NUMBERS_SPACE
          cursor
        else
          super
        end
      end
    end
  end
end
