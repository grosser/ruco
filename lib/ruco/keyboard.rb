require 'curses'

class Keyboard
  MAX_CHAR = 255
  ENTER = 13
  IS_18 = RUBY_VERSION =~ /^1\.8/
  SEQUENCE_TIMEOUT = 0.01
  NOTHING = 4294967295 # getch returns this as 'nothing' on 1.8 but nil on 1.9.2
  A_TO_Z = ('a'..'z').to_a

  def self.input(&block)
    @input = block
  end

  def self.output
    @sequence = nil
    @started = Time.now.to_f

    loop do
      key = fetch_user_input
      if sequence_finished?
        if needs_paste_fix?(@sequence)
          yield bytes_to_string(@sequence)
        else
          bytes_to_key_codes(@sequence).each{|c| yield c }
        end
        @sequence = nil
      end
      next if key == NOTHING
      start_or_append_sequence key
    end
  end

  private

  def self.translate_key_to_code(key)
    case key

    # move
    when Curses::Key::UP then :up
    when Curses::Key::DOWN then :down
    when Curses::Key::RIGHT then :right
    when Curses::Key::LEFT then :left
    when 554 then :"Ctrl+right"
    when 393 then :"Shift+left"
    when 555 then :"Ctrl+Shift+right"
    when 539 then :"Ctrl+left"
    when 402 then :"Shift+right"
    when 540 then :"Ctrl+Shift+left"
    when 560 then :"Ctrl+up"
    when 337 then :"Shift+up"
    when 519 then :"Ctrl+down"
    when 336 then :"Shift+down"
    when Curses::KEY_END then :end
    when Curses::KEY_HOME then :home
    when Curses::KEY_NPAGE then :page_down
    when Curses::KEY_PPAGE then :page_up
    when Curses::KEY_IC then :insert
    when Curses::KEY_F0..Curses::KEY_F63 then :"F#{key - Curses::KEY_F0}"

    # modify
    when 9 then :tab
    when ENTER then :enter # shadows Ctrl+m
    when 263, 127 then :backspace # ubuntu / mac
    when Curses::KEY_DC then :delete

    # misc
    when 0 then :"Ctrl+space"
    when 1..26 then :"Ctrl+#{A_TO_Z[key-1]}"
    when 27 then :escape
    when Curses::KEY_RESIZE then :resize
    else
      key > MAX_CHAR ? key : key.chr
    end
  end

  def self.fetch_user_input
    key = @input.call || NOTHING
    key = NOTHING if key > NOTHING # strange key codes when starting via ssh
    key = key.ord if key.is_a?(String) # ruby 1.9 fix
    key
  end

  def self.start_or_append_sequence(key)
    @started = Time.now.to_f
    @sequence ||= []
    @sequence << key
  end

  def self.bytes_to_string(bytes)
    bytes.pack('c*').gsub("\r","\n").force_encoding('utf-8')
  end

  # split a text so fast-typers do not get bugs like ^B^C in output
  def self.bytes_to_key_codes(bytes)
    result = []
    multi_byte = nil

    bytes.each do |byte|
      if multi_byte_part?(byte)
        multi_byte ||= []
        multi_byte << byte
      else
        if multi_byte
          # finish multi-byte char
          result << bytes_to_string(multi_byte)
          multi_byte = nil
        end
        result << translate_key_to_code(byte)
      end
    end

    if multi_byte
      result << bytes_to_string(multi_byte)
    end

    result
  end

  # not ascii and not control-char
  def self.multi_byte_part?(byte)
    127 < byte and byte < 256
  end

  def self.sequence_finished?
    @sequence and (Time.now.to_f - @started) > SEQUENCE_TIMEOUT
  end

  # paste of multiple \n or \n in text would cause weird indentation
  def self.needs_paste_fix?(sequence)
    sequence.size > 1 and sequence.include?(ENTER)
  end
end