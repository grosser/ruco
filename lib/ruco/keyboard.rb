class Keyboard
  SEQUENCE_TIMEOUT = 0.01
  NOTHING = 4294967295 # getch returns this as 'nothing' on 1.8 but nil on 1.9.2
  A_TO_Z = ('a'..'z').to_a

  def self.listen
    loop do
      key = Curses.getch || NOTHING

      if @sequence
        if sequence_finished?
          yield @sequence.pack('c*').force_encoding('utf-8')
          @sequence = nil
        else
          @sequence << key unless key == NOTHING
        end
        next
      end

      next if key == NOTHING
      log(key)


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
      when Curses::KEY_IC then :insert
      when Curses::KEY_F0..Curses::KEY_F63 then :"F#{key - Curses::KEY_F0}"

      # modify
      when 9 then :tab
      when 13 then :enter # shadows Ctrl+m
      when 263, 127 then :backspace # ubuntu / mac
      when Curses::KEY_DC then :delete

      # misc
      when 0 then :"Ctrl+space"
      when 1..26 then :"Ctrl+#{A_TO_Z[key-1]}"
      when 27 then :escape
      when 195..197 # start of unicode sequence
        @sequence = [key]
        @sequence_started = Time.now.to_f
        next
      else
        key > 255 ? key : key.chr # output printable chars
      end

      yield code
    end
  end

  private

  def self.sequence_finished?
    (Time.now.to_f - @sequence_started) > SEQUENCE_TIMEOUT
  end
end