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
          @screen.clear # clear cache
        else
          result = app.key key
        end
        break if result == :quit
        show_app app
      end
    end

    def show_app(app)
      log('xxx')
      lines = app.view.naive_split("\n")
      style_map = app.style_map

      # TODO move this logic into application
      display(lines, style_map)
      Curses.setpos(app.cursor.line, app.cursor.column)
    end


    def debug_key(key)
      @key_line ||= -1
      @key_line = (@key_line + 1) % Curses.stdscr.maxy
      write(@key_line, 0, "#{key.inspect}---")
    end

    def write(line,row,text)
      Curses.setpos(line,row)
      Curses.addstr(text);
    end

    def display(lines, style_mask)
      columns = Curses.stdscr.maxx
      @screen ||= [] # current screen is used as cache
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
        next if @screen[line] == [content, styles]
        @screen[line] = [content, styles]

        # position at start of line and draw
        Curses.setpos(line,0)
        Ruco::StyleMap.styled(content, styles).each do |style, part|
          Curses.attrset Ruco::StyleMap.curses_style(style)
          Curses.addstr part
        end

        if @options[:debug_cache]
          write(line, 0, (rand(899)+100).to_s)
        end
      end
    end
  end
end
