module Ruco
  class Editor
    module Colors
      def style_map
        map = super
        styled_lines = SyntaxParser.parse_lines(lines[@window.visible_lines], @options[:language])
        colorize(map, styled_lines)
        map
      end

      private

      def colorize(map, styled_lines)
        @@theme ||= Ruco::TMTheme.new('spec/fixtures/test.tmTheme')

        styled_lines.each_with_index do |style_positions, line|
          style_positions.each do |syntax_element, columns|
            columns = columns.move(-@window.left)
            _, style = @@theme.styles.detect{|name,style| syntax_element.start_with?(name) }
            if style and columns.first >= 0
              map.add(style, line, columns)
            end
          end
        end
      end
    end
  end
end
