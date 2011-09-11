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
          rules['settings']['foreground'],
          rules['settings']['background'],
        ]
        rules['scope'].split(/, ?/).each do |scope|
          @styles[scope.to_sym] = style
        end
      end
    end
  end
end
