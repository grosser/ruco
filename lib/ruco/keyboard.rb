class Keyboard
  def self.listen
    loop do
      key = Curses.getch

      case key

      # move
      when Curses::Key::UP then yield(:up)
      when Curses::Key::DOWN then yield(:down)
      when Curses::Key::RIGHT then yield(:right)
      when Curses::Key::LEFT then yield(:left)
      when Curses::KEY_END then yield(:end)
      when Curses::KEY_HOME then yield(:home)

      # modify
      when 9 then yield(:tab)
      when 32..126 then yield(key) # printable
      when 10 then yield(:enter)
      when 263 then yield(:backspace)
      when Curses::KEY_DC then yield(:delete)

      # misc
      when ?\C-d then yield(:"Ctrl+d")
      when ?\C-f then yield(:"Ctrl+f")
      when ?\C-g then yield(:"Ctrl+g")
      when 27 then yield(:escape)
      when ?\C-s then yield(:"Ctrl+s")
      when ?\C-w then yield(:"Ctrl+w")
      when ?\C-q then yield(:"Ctrl+q")
      end
    end
  end
end