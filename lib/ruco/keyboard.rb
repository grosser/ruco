require 'curses'

class Keyboard
  MAX_CHAR = 255
  ENTER = 13
  IS_18 = RUBY_VERSION =~ /^1\.8/
  SEQUENCE_TIMEOUT = 0.01
  NOTHING = (2**32 - 1) # getch returns this as 'nothing' on 1.8 but nil on 1.9.2
  A_TO_Z = ('a'..'z').to_a

  def self.input(&block)
    @input = block
  end

  def self.output
    @sequence = []
    @started = Time.now.to_f

    loop do
      key = fetch_user_input
      if sequence_finished?
        sequence_to_keys(@sequence).each{|k| yield k }
        @sequence = []
      end
      next unless key
      append_to_sequence key
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
    when 353 then :"Shift+tab"
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
    key = @input.call or return
    key = key.ord if key.is_a?(String) # ruby 1.9 fix
    return if key >= NOTHING
    key
  end

  def self.append_to_sequence(key)
    @started = Time.now.to_f
    @sequence << key
  end

  def self.bytes_to_string(bytes)
    bytes.pack('c*').gsub("\r","\n").force_encoding('utf-8')
  end

  # split a text so fast-typers do not get bugs like ^B^C in output
  def self.bytes_to_key_codes(bytes)
    result = []
    multi_byte = []

    append_multibyte = lambda{
      unless multi_byte.empty?
        result << bytes_to_string(multi_byte)
        multi_byte = []
      end
    }

    bytes.each do |byte|
      if multi_byte_part?(byte)
        multi_byte << byte
      else
        append_multibyte.call
        result << translate_key_to_code(byte)
      end
    end

    append_multibyte.call
    result
  end

  # not ascii and not control-char
  def self.multi_byte_part?(byte)
    127 < byte and byte < 256
  end

  def self.sequence_finished?
    @sequence.size != 0 and (Time.now.to_f - @started) > SEQUENCE_TIMEOUT
  end

  # paste of multiple \n or \n in text would cause weird indentation
  def self.needs_paste_fix?(sequence)
    sequence.size > 1 and sequence.include?(ENTER)
  end

  def self.sequence_to_keys(sequence)
    if needs_paste_fix?(sequence)
      [bytes_to_string(sequence)]
    else
      # when connected via ssh escape sequences are used
      if escape_sequence?(sequence)
        [escape_sequence_to_key(sequence)]
      else
        bytes_to_key_codes(sequence)
      end
    end
  end

  def self.escape_sequence?(sequence)
    sequence[0] == 27 # Esc
  end

  def self.escape_sequence_to_key(sequence)
    case sequence
    when [27, 91, 49, 59, 50, 65] then :"Shift+up"
    when [27, 91, 49, 59, 50, 66] then :"Shift+down"
    else
      if sequence.size == 2
        :"Alt+#{sequence[1].chr}"
      else
        bytes_to_string(sequence)
      end
    end
  end
end