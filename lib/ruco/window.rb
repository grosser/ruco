module Ruco
  class Window
    def initialize(lines, columns)
      @lines = lines
      @columns = columns
    end

    def crop(content)
      lines = content.slice(0, @lines)
      lines[@lines-1] ||= nil
      lines.map do |line|
        line ||= ''
        line.slice!(@columns, 99999) # drop everything we dont need
        line + (' ' * (@columns - line.size))
      end
    end
  end
end