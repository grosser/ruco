module Ruco
  class Editor
    module Colors
      RECOLORING_TIMEOUT = 2 # seconds
      INSTANT_RECOLORING_RANGE = 1 # recolor x lines around the current one

      def style_map
        map = super

        # add colors to style map
        colorize(map, styled_lines[@window.visible_lines])
        if @selection
          # add selection a second time so it stays on top
          @window.add_selection_styles(map, @selection)
        end
        map
      end

      private

      def styled_lines
        # initially color everything
        @@styled_lines ||= parse_lines
        @@last_recoloring ||= Time.now.to_f

        current_time = Time.now.to_f
        if @@last_recoloring + RECOLORING_TIMEOUT < current_time
          # re-color everything max every 2 seconds
          @@styled_lines = parse_lines
          @@last_recoloring = Time.now.to_f
        else
          # re-color the current + 2 surrounding lines (in case of line changes)
          recolor = [line - INSTANT_RECOLORING_RANGE, 0].max..(line + INSTANT_RECOLORING_RANGE)
          parsed = parse_lines(recolor)
          recolor.to_a.size.times{|i| parsed[i] ||= [] } # for empty lines [] => [[],[],[]]
          @@styled_lines[recolor] = parsed
        end

        @@styled_lines
      end

      def parse_lines(range=nil)
        parsed_lines = (range ? lines[range] : lines)
        SyntaxParser.parse_lines(parsed_lines, @options[:language])
      end

      def colorize(map, styled_lines)
        return unless styled_lines
        @@theme ||= Ruco::TMTheme.new('spec/fixtures/test.tmTheme')

        styled_lines.each_with_index do |style_positions, line|
          next unless style_positions
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
