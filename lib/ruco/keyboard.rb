class Keyboard
  A_TO_Z = ('a'..'z').to_a

  def self.listen
    loop do
      key = Curses.getch

      code = case key

      # move
      when Curses::Key::UP then :up
      when Curses::Key::DOWN then :down
      when Curses::Key::RIGHT then :right
      when Curses::Key::LEFT then :left
      when 554 then :"Ctrl+right"
      when 555 then :"Ctrl+Shift+right"
      when 539 then :"Ctrl+left"
      when 540 then :"Ctrl+Shift+left"
      when 560 then :"Ctrl+up"
      when 519 then :"Ctrl+down"
      when Curses::KEY_END then :end
      when Curses::KEY_HOME then :home
      when Curses::KEY_NPAGE then :page_down
      when Curses::KEY_PPAGE then :page_up

      # modify
      when 9 then :tab
      when 13 then :enter # shadows Ctrl+m
      when 263, 127 then :backspace # ubuntu / mac
      when Curses::KEY_DC then :delete

      # misc
      when 0 then :"Ctrl+space"
      when 1..26 then :"Ctrl+#{A_TO_Z[key-1]}"
      when 27 then :escape
      else
        key > 255 ? key : key.chr # output printable chars
      end

      yield code
    end
  end
end