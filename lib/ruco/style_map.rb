module Ruco
  class StyleMap
    attr_accessor :lines

    def initialize(lines)
      @lines = Array.new(lines)
    end

    def add(style, line, columns)
      @lines[line] ||= []
      @lines[line] << [style, columns]
    end

    def prepend(style, line, columns)
      @lines[line] ||= []
      @lines[line].unshift [style, columns]
    end

    def flatten
      @lines.map do |styles|
        next unless styles

        # start and one after end of every column-range changes styles
        points_of_change = styles.map{|s,c| [c.first, c.last+1] }.flatten.uniq

        flat = []

        styles.each do |style, columns|
          points_of_change.each do |point|
            next unless columns.include?(point)
            flat[point] = style
          end
        end

        max = styles.map{|_,columns| columns.last }.max
        flat[max+1] = :normal
        flat
      end
    end

    def left_pad!(offset)
      @lines.compact.each do |styles|
        next unless styles
        styles.map! do |style, columns|
          [style, (columns.first + offset)..(columns.last + offset)]
        end
      end
    end

    def invert!
      map = {:reverse => :normal, :normal => :reverse}
      @lines.compact.each do |styles|
        styles.map! do |style, columns|
          [map[style] || style, columns]
        end
      end
    end

    def +(other)
      lines = self.lines + other.lines
      new = StyleMap.new(0)
      new.lines = lines
      new
    end

    def slice!(*args)
      sliced = lines.slice!(*args)
      new = StyleMap.new(0)
      new.lines = sliced
      new
    end

    def shift
      slice!(0, 1)
    end

    def pop
      slice!(-1, 1)
    end

    def self.styled(content, styles)
      styles ||= []
      content = content.dup

      build = []
      build << [:normal]

      buffered = ''
      styles.each do |style|
        if style
          build[-1] << buffered
          buffered = ''

          # set new style
          build << [style]
        end
        buffered << (content.slice!(0,1) || '')
      end
      build[-1] << buffered + content
      build
    end

    STYLES = {
      :normal => 0,
      :reverse => Curses::A_REVERSE
    }

    def self.curses_style(style)
      return 0 unless style
      STYLES[style] or raise("Unknown style #{style.inspect}")
    end

    def self.single_line_reversed(columns)
      map = StyleMap.new(1)
      map.add(:reverse, 0, 0...columns)
      map
    end
  end
end
