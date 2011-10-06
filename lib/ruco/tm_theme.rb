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
      raise "Theme not found in #{file}" unless raw
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

        next if style == [nil, nil] # some weird themes have rules without colors...
        next unless scope = rules['scope'] # some weird themes have rules without scopes...

        scope.split(/, ?/).map(&:strip).each do |scope|
          @styles[scope] = style unless nested_scope?(scope)
        end
      end
    end

    private

    def nested_scope?(scope)
      scope.include?(' ')
    end
  end
end
