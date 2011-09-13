require 'plist'

module Ruco
  class TMTheme
    attr_accessor :background, :foreground, :styles

    # TODO maybe later...
    #attr_accessor :name, :uuid, :comment, :line_highlight

    # not supported in Curses ...
    #attr_accessor :invisibles, :caret, :selection

    def initialize(file)
      raw = Plist.parse_xml(file)
      rules = raw['settings']
      @styles = {}

      # set global styles
      global = rules.shift['settings']
      self.background = global['background']
      self.foreground = global['foreground']

      # set scope styles
      rules.each do |rules|
        style = [
          translate_color(rules['settings']['foreground']),
          translate_color(rules['settings']['background']),
        ]
        rules['scope'].split(/, ?/).each do |scope|
          @styles[scope] = style
        end
      end
    end

    HALF_COLOR = '7f'
    COLORS_8_BIT = {
      0 => :black,
      1 => :red,
      2 => :green,
      3 => :yellow,
      4 => :blue,
      5 => :magenta,
      6 => :cyan,
      7 => :white,
    }

    def translate_color(html_color)
      return unless html_color
      r = (html_color[1..2] > HALF_COLOR ? 1 : 0)
      g = (html_color[3..4] > HALF_COLOR ? 2 : 0)
      b = (html_color[5..6] > HALF_COLOR ? 4 : 0)
      COLORS_8_BIT[r + g + b]
    end
  end
end
