module Ruco
  class Editor
    module Colors
      def style_map
        map = super
        styled_lines = SyntaxParser.parse_lines(lines, @options[:language])
        colorize(map, styled_lines[@window.visible_lines])
        if @selection
          # add selection a second time so it stays on top
          @window.add_selection_styles(map, @selection)
        end
        map
      end

      private

      def colorize(map, styled_lines)
        @@theme ||= Ruco::TMTheme.new('spec/fixtures/test.tmTheme')

        styled_lines.each_with_index do |style_positions, line|
          style_positions.each do |syntax_element, columns|
            columns = columns.move(-@window.left)
            style = style_for_element(syntax_element)
            if style and columns.first >= 0
              map.add(style, line, columns)
            end
          end
        end
      end

      def style_for_element(syntax_element)
        @@style_for_element ||= {}
        @@style_for_element[syntax_element] ||= begin
          _, style = @@theme.styles.detect{|name,style| syntax_element.start_with?(name) }
          style
        end
      end
    end
  end
end
