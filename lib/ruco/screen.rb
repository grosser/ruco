module Ruco
  class Screen
    def initialize(options)
      @options = options
    end

    def open(&block)
      Curses.noecho # do not show typed chars
      Curses.nonl # turn off newline translation
      Curses.stdscr.keypad(true) # enable arrow keys
      Curses.raw # give us all other keys
      Curses.stdscr.nodelay = 1 # do not block -> we can use timeouts
      Curses.init_screen
      app = instance_exec(&block)
      show app
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

    private

    def show(app)
      show_app app

      Keyboard.input do
        Curses.getch
      end

      Keyboard.output do |key|
        debug_key(key) if @options[:debug_keys]
        if key == :resize
          app.resize(lines, columns)
          @display.clear # clear cache
        else
          result = app.key key
        end
        break if result == :quit
        show_app app
      end
    end

    def show_app(app)
      display(app.view, app.style_map)
      Curses.setpos(*app.cursor)
    end

    def debug_key(key)
      @key_line ||= -1
      @key_line = (@key_line + 1) % lines
      write(@key_line, 0, "#{key.inspect}---")
    end

    def write(line,row,text)
      Curses.setpos(line,row)
      Curses.addstr(text);
    end

    def display(view, style_mask)
      lines = view.naive_split("\n")
      @display ||= [] # current screen is used as cache
      style_mask = style_mask.flatten

      lines.each_with_index do |content, line|
        styles = style_mask[line]

        # expand line with whitespace to overwrite previous content
        missing = columns - content.size
        raise content if missing < 0
        content += " " * missing

        # display tabs as single-space -> nothing breaks
        content.gsub!("\t",' ')

        # cache !?
        next if @display[line] == [content, styles]
        @display[line] = [content, styles]

        # position at start of line and draw
        Curses.setpos(line,0)
        Ruco::StyleMap.styled(content, styles).each do |style, part|
          Curses.attrset self.class.curses_style(style)
          Curses.addstr part
        end

        if @options[:debug_cache]
          write(line, 0, (rand(899)+100).to_s)
        end
      end
    end

    STYLES = {
      :normal => 0,
      :reverse => Curses::A_REVERSE
    }

    def self.curses_style(style)
      return 0 unless style
      STYLES[style] or raise("Unknown style #{style.inspect}")
    end
  end
end
