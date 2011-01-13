class Keyboard
  def self.listen
    loop do
      key = Curses.getch

      code = case key

      # move
      when Curses::Key::UP then :up
      when Curses::Key::DOWN then :down
      when Curses::Key::RIGHT then :right
      when Curses::Key::LEFT then :left
      when Curses::KEY_END then :end
      when Curses::KEY_HOME then :home
      when Curses::KEY_NPAGE then :page_down
      when Curses::KEY_PPAGE then :page_up

      # modify
      when 9 then :tab
      when 32..126 then key # printable
      when 10 then :enter
      when 263, 127 then :backspace # ubuntu / mac
      when Curses::KEY_DC then :delete

      # misc
      when ?\C-d then :"Ctrl+d"
      when ?\C-f then :"Ctrl+f"
      when ?\C-g then :"Ctrl+g"
      when 27 then :escape
      when ?\C-s then :"Ctrl+s"
      when ?\C-w then :"Ctrl+w"
      when ?\C-q then :"Ctrl+q"
      else
        key
      end

      yield code
    end
  end
end