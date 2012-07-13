require 'curses'

class Keyboard
  MAX_CHAR = 255
  ENTER = 13
  ESCAPE = 27
  IS_18 = RUBY_VERSION =~ /^1\.8/
  SEQUENCE_TIMEOUT = 0.005
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

    # code, unix, iTerm
    when 337, '^[1;2A', "^[A" then :"Shift+up"
    when 336, '^[1;2B', "^[B" then :"Shift+down"
    when 402, '^[1;2C' then :"Shift+right"
    when 393, '^[1;2D' then :"Shift+left"

    when 558, '^[1;3A' then :"Alt+up"
    when 517, '^[1;3B' then :"Alt+down"
    when 552, '^[1;3C' then :"Alt+right"
    when 537, '^[1;3D' then :"Alt+left"

    when 560, '^[1;5A' then :"Ctrl+up"
    when 519, '^[1;5B' then :"Ctrl+down"
    when 554, '^[1;5C' then :"Ctrl+right"
    when 539, '^[1;5D' then :"Ctrl+left"

    when 561, '^[1;6A' then :"Ctrl+Shift+up"
    when 520, '^[1;6B' then :"Ctrl+Shift+down"
    when 555, '^[1;6C', "^[C" then :"Ctrl+Shift+right"
    when 540, '^[1;6D', "^[D" then :"Ctrl+Shift+left"

    when 562, '^[1;7A' then :"Alt+Ctrl+up"
    when 521, '^[1;7B' then :"Alt+Ctrl+down"
    when 556, '^[1;7C' then :"Alt+Ctrl+right"
    when 541, '^[1;7D' then :"Alt+Ctrl+left"

    when      '^[1;8A' then :"Alt+Ctrl+Shift+up"
    when      '^[1;8B' then :"Alt+Ctrl+Shift+down"
    when      '^[1;8C' then :"Alt+Ctrl+Shift+right"
    when      '^[1;8D' then :"Alt+Ctrl+Shift+left"

    when      '^[1;10A' then :"Alt+Shift+up"
    when      '^[1;10B' then :"Alt+Shift+down"
    when      '^[1;10C' then :"Alt+Shift+right"
    when      '^[1;10D' then :"Alt+Shift+left"

    when      '^[F'     then :"Shift+end"
    when      '^[H'     then :"Shift+home"

    when      '^[1;9F'  then :"Alt+end"
    when      '^[1;9H'  then :"Alt+home"

    when      '^[1;10F' then :"Alt+Shift+end"
    when      '^[1;10H' then :"Alt+Shift+home"

    when      '^[1;13F' then :"Alt+Ctrl+end"
    when      '^[1;13H' then :"Alt+Ctrl+home"

    when      '^[1;14F' then :"Alt+Ctrl+Shift+end"
    when      '^[1;14H' then :"Alt+Ctrl+Shift+home"

    when 527            then :"Ctrl+Shift+end"
    when 532            then :"Ctrl+Shift+home"

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
    when 263, 127 then :backspace
    when '^[3~', Curses::KEY_DC then :delete

    # misc
    when 0 then :"Ctrl+space"
    when 1..26 then :"Ctrl+#{A_TO_Z[key-1]}"
    when ESCAPE then :escape
    when Curses::KEY_RESIZE then :resize
    else
      if key.is_a? Fixnum
        key > MAX_CHAR ? key : key.chr
      elsif is_alt_key_code?(key)
        :"Alt+#{key.slice(1,1)}"
      else
        key
      end
    end
  end

  def self.fetch_user_input
    key = @input.call or return
    key = key.ord unless IS_18
    if key >= NOTHING
      # nothing happening -> sleep a bit to save cpu
      sleep SEQUENCE_TIMEOUT
      return
    end
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
        stringified = bytes_to_string(sequence).sub("\e",'^').sub('[[','[')
        [translate_key_to_code(stringified)]
      else
        bytes_to_key_codes(sequence)
      end
    end
  end

  def self.escape_sequence?(sequence)
    sequence[0] == ESCAPE and sequence.size.between?(2,7)
  end

  def self.is_alt_key_code?(sequence)
    sequence.slice(0,1) == "^" and sequence.size == 2
  end
end
