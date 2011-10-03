require 'timeout'

module Ruco
  class Editor
    module Colors
      DEFAULT_THEME = File.expand_path('../../../../spec/fixtures/railscasts.tmTheme',__FILE__)
      STYLING_TIMEOUT = 4

      def style_map
        return super if @colors_took_too_long or not @options[:language]
        map = super

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

        $ruco_foreground = theme.foreground
        $ruco_background = theme.background

        if syntax
          add_syntax_highlighting_to_style_map(map, syntax)

          # add selection a second time so it stays on top
          @window.add_selection_styles(map, @selection) if @selection
        end

        map
      end

      private

      def syntax_info
        language = @options[:language]
        possible_languages = [language.name.downcase, language.lexer]

        @syntax_info ||= {}
        lines.map do |line|
          @syntax_info[line] ||= SyntaxParser.syntax_for_lines([line], possible_languages).first
        end
      end

      def add_syntax_highlighting_to_style_map(map, syntax_info)
        syntax_info.each_with_index do |syntax_positions, line|
          next unless syntax_positions

          syntax_positions.each do |syntax_element, columns|
            next unless style = style_for_syntax_element(syntax_element)
            next unless columns = adjust_columns_to_window_position(columns, @window.left)
            map.add(style, line, columns)
          end
        end
      end

      def adjust_columns_to_window_position(columns, left)
        return columns if left == 0

        # style is out of scope -> add nothing
        return nil if columns.last_element <= left

        # shift style to the left
        first = [0, columns.first - left].max
        last = columns.last_element - left
        first..last
      end

      def style_for_syntax_element(syntax_element)
        _, style = theme.styles.detect{|name,style| syntax_element.start_with?(name) }
        style
      end
      memoize :style_for_syntax_element

      def theme
        file = download_into_file(@options[:color_theme]) if @options[:color_theme]
        file ||= DEFAULT_THEME
        Ruco::TMTheme.new(file)
      end
      memoize :theme

      def download_into_file(url)
        theme_store = FileStore.new('~/.ruco/cache', :string => true)
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
