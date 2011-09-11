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
          simple_color(rules['settings']['foreground']),
          simple_color(rules['settings']['background']),
        ]
        rules['scope'].split(/, ?/).each do |scope|
          @styles[scope] = style
        end
      end
    end

    def simple_color(html_color)
      return unless html_color
      return :white if html_color == '#ffffff'
      return :black if html_color == '#000000'

      red = html_color[1..2]
      green = html_color[3..4]
      blue = html_color[5..6]
      if red > green and red > blue
        :red
      elsif green > red and green > blue
        :green
      else
        :blue
      end
    end
  end
end
