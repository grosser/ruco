require 'timeout'

module Ruco
  class Editor
    module Colors
      RECOLORING_TIMEOUT = 30 # seconds
      INSTANT_RECOLORING_RANGE = 1 # recolor x lines around the current one
      DEFAULT_THEME = 'spec/fixtures/test.tmTheme'
      STYLING_TIMEOUT = 4

      def style_map
        map = super
        return map if @colors_took_too_long

        # disable colors if syntax-parsing takes too long
        begin
          syntax = Timeout.timeout(STYLING_TIMEOUT) do
            syntax_info[@window.visible_lines]
          end
        rescue Timeout::Error
          # this takes too long, just go on without styles
          STDERR.puts "Styling takes too long, go on without me!"
          @colors_took_too_long = true
          return map
        end

        add_syntax_highlighting_to_style_map(map, syntax)

        if @selection
          # add selection a second time so it stays on top
          @window.add_selection_styles(map, @selection)
        end
        map
      end

      private

      def syntax_info
        # initially color everything
        @@syntax_info ||= syntax_for_lines
        @@last_recoloring ||= Time.now.to_f

        current_time = Time.now.to_f
        if @@last_recoloring + RECOLORING_TIMEOUT < current_time
          # re-color everything max every 2 seconds
          @@syntax_info = syntax_for_lines
          @@last_recoloring = Time.now.to_f
        else
          # re-color the current + 2 surrounding lines (in case of line changes)
          lines_to_recolor = [line - INSTANT_RECOLORING_RANGE, 0].max..(line + INSTANT_RECOLORING_RANGE)
          parsed = syntax_for_lines(lines_to_recolor)
          lines_to_recolor.to_a.size.times{|i| parsed[i] ||= [] } # for empty lines [] => [[],[],[]]
          @@syntax_info[lines_to_recolor] = parsed
        end

        @@syntax_info
      end

      def syntax_for_lines(range=nil)
        if language = @options[:language]
          lines_to_parse = (range ? lines[range] : lines)
          SyntaxParser.syntax_for_lines(lines_to_parse, [language.name.downcase, language.lexer])
        else
          []
        end
      end

      def add_syntax_highlighting_to_style_map(map, syntax_info)
        return unless syntax_info

        syntax_info.each_with_index do |syntax_positions, line|
          next unless syntax_positions
          syntax_positions.each do |syntax_element, columns|
            columns = columns.move(-@window.left)
            style = style_for_syntax_element(syntax_element)
            if style and columns.first >= 0
              map.add(style, line, columns)
            end
          end
        end
      end

      def style_for_syntax_element(syntax_element)
        @theme ||= Ruco::TMTheme.new(theme_file)
        @style_for_element ||= {}
        @style_for_element[syntax_element] ||= begin
          _, style = @theme.styles.detect{|name,style| syntax_element.start_with?(name) }
          style
        end
      end

      def theme_file
        file = download_into_file(@options[:color_theme]) if @options[:color_theme]
        file || DEFAULT_THEME
      end

      def download_into_file(url)
        theme_store = FileStore.new(File.expand_path('~/.ruco/themes'), :keep => 5, :pure => true)
        theme_store.cache(url) do
          require 'open-uri'
          require 'openssl'
          OpenURI.without_ssl_verification do
            open(url).read
          end
        end
        File.expand_path(theme_store.file(url))
      rescue => e
        STDERR.puts "Could not download #{url} -- #{e}"
      end
    end
  end
end
