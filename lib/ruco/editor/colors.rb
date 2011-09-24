require 'timeout'

module Ruco
  class Editor
    module Colors
      DEFAULT_THEME = File.expand_path('../../../../spec/fixtures/railscasts.tmTheme',__FILE__)
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
        if language = @options[:language]
          @syntax_info ||= {}
          language = [language.name.downcase, language.lexer]
          lines.map do |line|
            @syntax_info[line] ||= SyntaxParser.syntax_for_lines([line], language).first
          end
        else
          []
        end
      end

      def add_syntax_highlighting_to_style_map(map, syntax_info)
        return unless syntax_info

        $ruco_foreground = theme.foreground
        $ruco_background = theme.background

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
        @style_for_element ||= {}
        @style_for_element[syntax_element] ||= begin
          _, style = theme.styles.detect{|name,style| syntax_element.start_with?(name) }
          style
        end
      end

      def theme
        @theme ||= begin
          file = download_into_file(@options[:color_theme]) if @options[:color_theme]
          file ||= DEFAULT_THEME
          Ruco::TMTheme.new(file)
        end
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
