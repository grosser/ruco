module Ruco
  class Screen
    @@styles = {}

    COLORS = {
      :black => Curses::COLOR_BLACK,
      :white => Curses::COLOR_WHITE,
      :blue => Curses::COLOR_BLUE,
      :yellow => Curses::COLOR_YELLOW,
      :red => Curses::COLOR_RED,
      :green => Curses::COLOR_GREEN,
      :magenta => Curses::COLOR_MAGENTA,
      :cyan => Curses::COLOR_CYAN,
    }

    def initialize(options)
      @options = options
      @cache = []
    end

    def self.open(options, &block)
      new(options).open(&block)
    end

    def open(&block)
      Curses.noecho # do not show typed chars
      Curses.nonl # turn off newline translation
      Curses.stdscr.keypad(true) # enable arrow keys
      Curses.raw # give us all other keys
      Curses.stdscr.nodelay = 1 # do not block -> we can use timeouts
      Curses.init_screen
      Curses.start_color if Curses.has_colors?
      yield self
    ensure
      Curses.clear # needed to clear the menu/status bar on windows
      Curses.close_screen
    end

    def columns
      Curses.stdscr.maxx
    end

    def lines
      Curses.stdscr.maxy
    end

    def clear_cache
      @cache.clear
    end

    def draw(view, style_map, cursor)
      draw_view(view, style_map)
      Curses.setpos(*cursor)
    end

    def debug_key(key)
      @key_line ||= -1
      @key_line = (@key_line + 1) % lines
      write(@key_line, 0, "#{key.inspect}---")
    end

    private

    def write(line,row,text)
      Curses.setpos(line,row)
      Curses.addstr(text);
    end

    def draw_view(view, style_mask)
      lines = view.naive_split("\n")
      style_mask = style_mask.flatten

      lines.each_with_index do |line, line_number|
        styles = style_mask[line_number]

        # expand line with whitespace to overwrite previous content
        missing = columns - line.size
        raise line if missing < 0
        line += " " * missing

        # display tabs as single-space -> nothing breaks
        line.gsub!("\t",' ')

        if_line_changes line_number, [line, styles] do
          # position at start of line and draw
          Curses.setpos(line_number,0)
          Ruco::StyleMap.styled(line, styles).each do |style, part|
            Curses.attrset self.class.curses_style(style)
            Curses.addstr part
          end

          if @options[:debug_cache]
            write(line_number, 0, (rand(899)+100).to_s)
          end
        end
      end
    end

    def if_line_changes(key, args)
      return if @cache[key] == args # would not change the line -> nothing to do
      @cache[key] = args # store current line
      yield # render the line
    end

    def self.curses_style(style)
      @@styles[style] ||= begin
        foreground = :white
        background = :black # background white does not work well since is is more like pink

        foreground, background = if style == :normal
          [foreground, background]
        elsif style == :reverse
          [background, foreground]
        else
          # :red or [:red, :blue]
          f,b = style
          b ||= background
          [f,b]
        end

        foreground = translate_style_to_curses(foreground)
        background = translate_style_to_curses(background)

        color_id(foreground, background)
      end
    end

    def self.translate_style_to_curses(color)
      COLORS[color] || raise("Unknown color #{color.inspect}")
    end

    # create a new color from foreground+background or reuse old
    # and return color-id
    def self.color_id(foreground, background)
      @@color_ids ||= {}
      @@color_ids[[foreground, background]] ||= begin
        # make a new pair with a unique id
        @@max_color_id ||= 0
        id = (@@max_color_id += 1)
        unless defined? RSpec # stops normal text-output, do not use in tests
          Curses::init_pair(id, foreground, background)
        end
        Curses.color_pair(id)
      end
    end
  end
end
