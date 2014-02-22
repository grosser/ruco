require "spec_helper"

describe Ruco::Editor do
  def write(content)
    File.open(@file,'wb'){|f| f.write(content) }
  end

  def read
    File.binary_read(@file)
  end

  def color(c)
    {
      :string => ["#718C00", nil],
      :keyword => ["#8959A8", nil],
      :instance_variable => ["#C82829", nil],
    }[c]
  end

  let(:language){ LanguageSniffer::Language.new(:name => 'ruby', :lexer => 'ruby') }
  let(:editor){
    editor = Ruco::Editor.new(@file, :lines => 3, :columns => 5, :language => language)
    # only scroll when we reach end of lines/columns <-> able to test with smaller area
    editor.send(:text_area).instance_eval{
      @window.instance_eval{
        @options[:line_scroll_threshold] = 0
        @options[:line_scroll_offset] = 1
        @options[:column_scroll_threshold] = 0
        @options[:column_scroll_offset] = 1
      }
    }
    editor
  }

  before do
    `rm -rf ~/.ruco/sessions`
    @file = 'spec/temp.txt'
    write('')
  end

  describe "strange newline formats" do
    it 'views \r normally' do
      write("a\rb\rc\r")
      editor.view.should == "a\nb\nc"
    end

    it 'views \r\n normally' do
      write("a\r\nb\r\nc\r\n")
      editor.view.should == "a\nb\nc"
    end

    it 'saves \r as \r' do
      write("a\rb\rc\r")
      editor.save
      read.should == "a\rb\rc\r"
    end

    it 'saves \r\n as \r\n' do
      write("a\r\nb\r\nc\r\n")
      editor.save
      read.should == "a\r\nb\r\nc\r\n"
    end

    it "converts mixed formats to first" do
      write("a\rb\r\nc\n")
      editor.save
      read.should == "a\rb\rc\r"
    end

    it "converts newline-free to \n" do
      write("a")
      editor.insert("\n")
      editor.save
      read.should == "\na"
    end

    it "is not modified after saving strange newline format" do
      write("a\r\nb\r\nc\r\n")
      editor.save
      editor.modified?.should == false
    end
  end

  describe 'blank line before end of file on save' do
    it "adds a newline" do
      write("aaa")
      editor = Ruco::Editor.new(@file, :lines => 3, :columns => 5, :blank_line_before_eof_on_save => true)
      editor.save
      read.should == "aaa\n"
    end

    it "does not add a newline without option" do
      write("aaa")
      editor = Ruco::Editor.new(@file, :lines => 3, :columns => 5)
      editor.save
      read.should == "aaa"
    end

    it "adds weird newline" do
      write("aaa\r\nbbb")
      editor = Ruco::Editor.new(@file, :lines => 3, :columns => 5, :blank_line_before_eof_on_save => true)
      editor.save
      read.should == "aaa\r\nbbb\r\n"
    end

    it "does not add a newline for empty lines" do
      write("aaa\n ")
      editor = Ruco::Editor.new(@file, :lines => 3, :columns => 5, :blank_line_before_eof_on_save => true)
      editor.save
      read.should == "aaa\n "
    end

    it "does not add a newline when one is there" do
      write("aaa\n")
      editor = Ruco::Editor.new(@file, :lines => 3, :columns => 5, :blank_line_before_eof_on_save => true)
      editor.save
      read.should == "aaa\n"
    end

    it "does not add a weird newline when one is there" do
      write("aaa\r\n")
      editor = Ruco::Editor.new(@file, :lines => 3, :columns => 5, :blank_line_before_eof_on_save => true)
      editor.save
      read.should == "aaa\r\n"
    end

    it "does not add a newline when many are there" do
      write("aaa\n\n")
      editor = Ruco::Editor.new(@file, :lines => 3, :columns => 5, :blank_line_before_eof_on_save => true)
      editor.save
      read.should == "aaa\n\n"
    end
  end

  describe 'convert tabs' do
    before do
      write("\t\ta")
    end

    it "reads tab as spaces when option is set" do
      editor = Ruco::Editor.new(@file, :lines => 3, :columns => 5, :convert_tabs => true)
      editor.view.should == "    a\n\n"
    end

    it "reads them normally when option is not set" do
      editor = Ruco::Editor.new(@file, :lines => 3, :columns => 5)
      editor.view.should == "\t\ta\n\n"
    end
  end

  describe 'huge-files' do
    it "does not try to open huge files" do
      write('a'*(1024*1024 + 1))
      lambda{
        Ruco::Editor.new(@file, :lines => 3, :columns => 5)
      }.should raise_error
    end

    it "opens large files and does not take forever" do
      write('a'*(1024*1024))
      Time.benchmark do
        editor = Ruco::Editor.new(@file, :lines => 3, :columns => 5)
        editor.view
      end.should < 1
    end
  end

  describe :move do
    before do
      write("    \n    \n    ")
    end

    it "starts at 0,0" do
      editor.cursor.should == [0,0]
    end

    it "can move" do
      editor.move(:relative, 1,2)
      editor.cursor.should == [1,2]
      editor.move(:relative, 1,1)
      editor.cursor.should == [2,3]
    end

    it "can move in empty file" do
      write("\n\n\n")
      editor.move(:relative, 2,0)
      editor.cursor.should == [2,0]
    end

    it "cannot move left/top off screen" do
      editor.move(:relative, -1,-1)
      editor.cursor.should == [0,0]
    end

    it "does not move lines when jumping right" do
      editor.move(:relative, 1, 5)
      editor.cursor.should == [1,4]
    end

    it "does not move lines when jumping left" do
      editor.move(:to, 2, 2)
      editor.move(:relative, -1, -5)
      editor.cursor.should == [1,0]
    end

    it "moves to next line when moving right of characters" do
      editor.move(:relative, 0, 5)
      editor.cursor.should == [1,0]
    end

    it "moves to prev line when moving left of characters" do
      editor.move(:relative, 1, 0)
      editor.move(:relative, 0, -1)
      editor.cursor.should == [0,4]
    end

    it "stays at origin when moving left" do
      editor.move(:relative, 0, -1)
      editor.cursor.should == [0,0]
    end

    it "stays at eof when moving right" do
      editor.move(:to, 2, 4)
      editor.move(:relative, 0, 1)
      editor.cursor.should == [2,4]
    end

    it "stays in last line when moving past lines" do
      write("    ")
      editor.move(:relative, 6,3)
      editor.cursor.should == [0,3]
    end

    describe 'column scrolling' do
      it "can scroll columns" do
        write("123456789\n123")
        editor.move(:relative, 0,4)
        editor.view.should == "12345\n123\n"
        editor.cursor.column.should == 4

        editor.move(:relative, 0,1)
        editor.view.should == "34567\n3\n"
        editor.cursor.column.should == 3
      end

      it "cannot scroll past the screen" do
        write('123456789')
        editor.move(:relative, 0,4)
        6.times{ editor.move(:relative, 0,1) }
        editor.view.should == "789\n\n"
        editor.cursor.column.should == 3
      end

      it "can scroll columns backwards" do
        write('0123456789')
        editor.move(:relative, 0,5)
        editor.view.should == "23456\n\n"

        editor.move(:relative, 0,-4)
        editor.view.should == "01234\n\n"
        editor.cursor.column.should == 1
      end
    end

    describe 'line scrolling' do
      before do
        write("1\n2\n3\n4\n5\n6\n7\n8\n9")
      end

      it "can scroll lines down" do
        editor.move(:relative, 2,0)
        editor.view.should == "1\n2\n3"

        editor.move(:relative, 1,0)
        editor.view.should == "3\n4\n5"
        editor.cursor.line.should == 1
      end

      it "can scroll till end of file" do
        editor.move(:relative, 15,0)
        editor.view.should == "8\n9\n"
        editor.cursor.line.should == 1
      end
    end

    describe :to do
      it "cannot move outside of text (bottom/right)" do
        write("123\n456")
        editor.move(:to, 10,10)
        editor.cursor.should == [1,3]
      end

      it "cannot move outside of text (top/left)" do
        write("123\n456")
        editor.move(:relative, 1,1)
        editor.move(:to, -10,-10)
        editor.cursor.should == [0,0]
      end
    end

    describe :to_eol do
      before do
        write("\n aa \n  ")
      end

      it 'stays at start when line is empty' do
        editor.move :to_eol
        editor.cursor.should == [0,0]
      end

      it 'moves after last word if cursor was before it' do
        editor.move(:relative, 1,1)
        editor.move :to_eol
        editor.cursor.should == [1,3]
      end

      it 'moves after last whitespace if cursor was after last word' do
        editor.move(:relative, 1,3)
        editor.move :to_eol
        editor.cursor.should == [1,4]
      end

      it 'moves after last work if cursor was after last whitespace' do
        editor.move(:relative, 1,4)
        editor.move :to_eol
        editor.cursor.should == [1,3]
      end
    end

    describe :to_bol do
      before do
        write("\n  aa \n  ")
      end

      it 'stays at start when line is empty' do
        editor.move :to_bol
        editor.cursor.should == [0,0]
      end

      it 'moves before first work if at start of line' do
        editor.move(:relative, 1,0)
        editor.move :to_bol
        editor.cursor.should == [1,2]
      end

      it 'moves to start of line if before first word' do
        editor.move(:relative, 1,1)
        editor.move :to_bol
        editor.cursor.should == [1,0]

        editor.move(:relative, 0,2)
        editor.move :to_bol
        editor.cursor.should == [1,0]
      end

      it 'moves before first word if inside line' do
        editor.move(:relative, 1,5)
        editor.move :to_bol
        editor.cursor.should == [1,2]
      end
    end

    describe 'jumping' do
      it "can jump right" do
        write("abc def")
        editor.move(:jump, :right)
        editor.cursor.should == [0,3]
      end

      it "does not jump over braces" do
        write("abc(def")
        editor.move(:jump, :right)
        editor.cursor.should == [0,3]
      end

      it "can jump over whitespace and newlines" do
        write("abc\n 123")
        editor.move(:jump, :right)
        editor.cursor.should == [0,3]
        editor.move(:jump, :right)
        editor.cursor.should == [1,1]
      end

      it "can jump left" do
        write("abc def")
        editor.move(:relative, 0,3)
        editor.move(:jump, :left)
        editor.cursor.should == [0,0]
      end

      it "can jump to start" do
        write("abc\ndef")
        editor.move(:relative, 0,2)
        editor.move(:jump, :left)
        editor.cursor.should == [0,0]
      end

      it "stays at start" do
        write("abc\ndef")
        editor.move(:jump, :left)
        editor.cursor.should == [0,0]
      end

      it "can jump to end" do
        write("abc\ndef")
        editor.move(:relative, 1,1)
        editor.move(:jump, :right)
        editor.cursor.should == [1,3]
      end

      it "stays at end" do
        write("abc\ndef")
        editor.move(:to, 1,3)
        editor.move(:jump, :right)
        editor.cursor.should == [1,3]
      end
    end
  end

  describe :move_line do
    before do
      write("0\n1\n2\n")
    end

    it "moves the line" do
      editor.move_line(1)
      editor.view.should == "1\n0\n2"
    end

    it "keeps the cursor at the moved line" do
      editor.move_line(1)
      editor.cursor.should == [1,0]
    end

    it "keeps the cursor at current column" do
      editor.move(:to, 0,1)
      editor.move_line(1)
      editor.cursor.should == [1,1]
    end

    it "uses indentation of moved-to-line" do
      write("  0\n    1\n 2\n")
      editor.move_line(1)
      editor.view.should == "    1\n    0\n 2"
    end

    it "cannot move past start of file" do
      editor.move_line(-1)
      editor.view.should == "0\n1\n2"
    end

    it "cannot move past end of file" do
      write("0\n1\n")
      editor.move_line(1)
      editor.move_line(1)
      editor.move_line(1)
      editor.move_line(1)
      editor.view.should == "1\n\n0"
    end
  end

  describe :selecting do
    before do
      write('012345678')
    end

    it "remembers the selection" do
      editor.selecting do
        move(:to, 0, 4)
      end
      editor.selection.should == ([0,0]..[0,4])
    end

    it "expands the selection" do
      editor.selecting do
        move(:to, 0, 4)
        move(:to, 0, 6)
      end
      editor.selection.should == ([0,0]..[0,6])
    end

    it "expand an old selection" do
      editor.selecting do
        move(:to, 0, 4)
      end
      editor.selecting do
        move(:relative, 0, 2)
      end
      editor.selection.should == ([0,0]..[0,6])
    end

    it "can select backwards" do
      editor.move(:to, 0, 4)
      editor.selecting do
        move(:relative, 0, -2)
      end
      editor.selecting do
        move(:relative, 0, -2)
      end
      editor.selection.should == ([0,0]..[0,4])
    end

    it "can select multiple lines" do
      write("012\n345\n678")
      editor.move(:to, 0, 2)
      editor.selecting do
        move(:relative, 1, 0)
      end
      editor.selecting do
        move(:relative, 1, 0)
      end
      editor.selection.should == ([0,2]..[2,2])
    end

    it "clears the selection once I move" do
      editor.selecting do
        move(:to, 0, 4)
      end
      editor.move(:relative, 0, 2)
      editor.selection.should == nil
    end

    it "replaces the selection with insert" do
      editor.selecting do
        move(:to, 0, 4)
      end
      editor.insert('X')
      editor.selection.should == nil
      editor.cursor.should == [0,1]
      editor.move(:to, 0,0)
      editor.view.should == "X4567\n\n"
    end

    it "replaces the multi-line-selection with insert" do
      write("123\n456\n789")
      editor.move(:to, 0,1)
      editor.selecting do
        move(:to, 1,2)
      end
      editor.insert('X')
      editor.selection.should == nil
      editor.cursor.should == [0,2]
      editor.move(:to, 0,0)
      editor.view.should == "1X6\n789\n"
    end

    it "deletes selection delete" do
      write("123\n456\n789")
      editor.move(:to, 0,1)
      editor.selecting do
        move(:to, 1,2)
      end
      editor.delete(1)
      editor.cursor.should == [0,1]
      editor.move(:to, 0,0)
      editor.view.should == "16\n789\n"
    end
  end

  describe :text_in_selection do
    before do
      write("123\n456\n789")
    end

    it "returns '' if nothing is selected" do
      editor.selecting do
        move(:to, 1,1)
      end
      editor.text_in_selection.should == "123\n4"
    end

    it "returns selected text" do
      editor.text_in_selection.should == ''
    end
  end

  describe :style_map do
    it "is empty by default" do
      editor.style_map.flatten.should == [nil,nil,nil]
    end

    it "shows one-line selection" do
      write('abcdefghi')
      editor.selecting do
        move(:to, 0, 4)
      end
      editor.style_map.flatten.should == [
        [:reverse, nil, nil, nil, :normal],
        nil,
        nil
      ]
    end

    it "shows multi-line selection" do
      write("abc\nabc\nabc")
      editor.move(:to, 0,1)
      editor.selecting do
        move(:to, 1, 1)
      end
      editor.style_map.flatten.should == [
        [nil, :reverse, nil, nil, nil, :normal],
        [:reverse, :normal],
        nil
      ]
    end

    it "shows the selection from offset" do
      write('abcdefghi')
      editor.move(:to, 0, 2)
      editor.selecting do
        move(:to, 0, 4)
      end
      editor.style_map.flatten.should == [
        [nil, nil, :reverse, nil, :normal],
        nil,
        nil
      ]
    end

    it "shows the selection in nth line" do
      write("\nabcdefghi")
      editor.move(:to, 1, 2)
      editor.selecting do
        move(:to, 1, 4)
      end
      editor.style_map.flatten.should == [
        nil,
        [nil, nil, :reverse, nil, :normal],
        nil
      ]
    end

    it "shows multi-line selection in scrolled space" do
      write("\n\n\n\n\nacdefghijk\nacdefghijk\nacdefghijk\n\n")
      ta = editor.send(:text_area)
      ta.send(:position=, [5,8])
      ta.send(:screen_position=, [5,7])
      editor.selecting do
        move(:relative, 2, 1)
      end
      editor.view.should == "ijk\nijk\nijk"
      editor.cursor.should == [2,2]
      editor.style_map.flatten.should == [
        [nil, :reverse, nil, nil, nil, :normal], # start to end of screen
        [:reverse, nil, nil, nil, nil, :normal], # 0 to end of screen
        [:reverse, nil, :normal] # 0 to end of selection
      ]
    end

    it "shows keywords" do
      write("class")
      editor.style_map.flatten.should == [
        [color(:keyword), nil, nil, nil, nil, :normal],
        nil,
        nil
      ]
    end

    it "shows keywords for moved window" do
      write("\n\n\n\n\n     if  ")
      editor.move(:to, 5, 6)
      editor.cursor.should == [1,3]
      editor.view.should == "\n  if \n"
      editor.style_map.flatten.should == [
        nil,
        [nil, nil, color(:keyword), nil, :normal],
        nil
      ]
    end

    it "shows mid-keywords for moved window" do
      write("\n\n\n\n\nclass ")
      editor.move(:to, 5, 6)
      editor.cursor.should == [1,3]
      editor.view.should == "\nss \n"
      editor.style_map.flatten.should == [
        nil,
        [color(:keyword), nil, :normal],
        nil
      ]
    end

    it "shows multiple syntax elements" do
      write("if @x")
      editor.style_map.flatten.should == [
        [color(:keyword), nil, :normal, color(:instance_variable), nil, :normal],
        nil,
        nil
      ]
    end

    it "does not show keywords inside strings" do
      write("'Foo'")
      editor.style_map.flatten.should == [
        [color(:string), nil, nil, nil, nil, :normal],
        nil,
        nil
      ]
    end

    xit "shows multiline comments" do
      write("=begin\na\nb\n=end")
      editor.move(:to, 3,0)
      editor.view.should == "b\n=end\n"
      editor.style_map.flatten.should == [
        [["#8E908C", nil], nil, :normal],
        [["#8E908C", nil], nil, nil, nil, :normal],
        nil
      ]
    end

    it "shows selection on top" do
      write("class")
      editor.selecting do
        move(:relative, 0, 3)
      end
      editor.style_map.flatten.should == [
        [:reverse, nil, nil, ["#8959A8", nil], nil, :normal],
        nil,
        nil
      ]
    end

    it "times out when styling takes too long" do
      STDERR.should_receive(:puts)
      Timeout.should_receive(:timeout).and_raise Timeout::Error
      write(File.read('lib/ruco.rb'))
      editor.style_map.flatten.should == [nil,nil,nil]
    end

    describe 'with theme' do
      before do
        write("class")
        `rm -rf ~/.ruco/themes`
      end

      it "can download a theme" do
        editor = Ruco::Editor.new(@file,
          :lines => 3, :columns => 5, :language => language,
          :color_theme => 'https://raw.github.com/ChrisKempson/TextMate-Tomorrow-Theme/master/Tomorrow-Night-Bright.tmTheme'
        )
        editor.style_map.flatten.should == [
          [["#C397D8", nil], nil, nil, nil, nil, :normal],
          nil,
          nil
        ]
      end

      it "does not fail with invalid theme url" do
        STDERR.should_receive(:puts)
        editor = Ruco::Editor.new(@file,
          :lines => 3, :columns => 5, :language => language,
          :color_theme => 'foooooo'
        )
        editor.style_map.flatten.should == [
          [["#8959A8", nil], nil, nil, nil, nil, :normal],
          nil,
          nil
        ]
      end
    end
  end

  describe :view do
    before do
      write('')
    end

    it "displays an empty screen" do
      editor.view.should == "\n\n"
    end

    it "displays short file content" do
      write('xxx')
      editor.view.should == "xxx\n\n"
    end

    it "displays long file content" do
      write('1234567')
      editor.view.should == "12345\n\n"
    end

    it "displays multiline-file content" do
      write("xxx\nyyy\nzzz\niii")
      editor.view.should == "xxx\nyyy\nzzz"
    end
  end

  describe :insert do
    before do
      write('')
    end

    it "can insert new chars" do
      write('123')
      editor.move(:relative, 0,1)
      editor.insert('ab')
      editor.view.should == "1ab23\n\n"
      editor.cursor.should == [0,3]
    end

    it "can insert new newlines" do
      editor.insert("ab\nc")
      editor.view.should == "ab\nc\n"
      editor.cursor.should == [1,1]
    end

    it "jumps to correct column when inserting newline" do
      write("abc\ndefg")
      editor.move(:relative, 1,2)
      editor.insert("1\n23")
      editor.view.should == "abc\nde1\n23fg"
      editor.cursor.should == [2,2]
    end

    it "jumps to correct column when inserting 1 newline" do
      write("abc\ndefg")
      editor.move(:relative, 1,2)
      editor.insert("\n")
      editor.view.should == "abc\nde\nfg"
      editor.cursor.should == [2,0]
    end

    it "can add newlines to the end" do
      write('')
      editor.insert("\n")
      editor.insert("\n")
      editor.cursor.should == [2,0]
    end

    it "can add newlines to the moveable end" do
      write('abc')
      editor.move(:relative, 0,3)
      editor.insert("\n")
      editor.insert("\n")
      editor.cursor.should == [2,0]
    end

    it "inserts tab as spaces" do
      editor.insert("\t")
      editor.view.should == "  \n\n"
      editor.cursor.should == [0,2]
    end

    it "keeps indentation" do
      write("ab\n  cd")
      editor.move(:to, 1,2)
      editor.insert("\n")
    end
  end

  describe :indent do
    it "indents selected lines" do
      write("a\nb\nc\n")
      editor.selecting{move(:to, 1,1)}
      editor.indent
      editor.view.should == "  a\n  b\nc"
    end

    it "moves the selection" do
      write("a\nb\nc\n")
      editor.selecting{move(:to, 1,1)}
      editor.indent
      editor.selection.should == ([0,2]..[1,3])
    end

    it "moves the cursor" do
      write("a\nb\nc\n")
      editor.selecting{move(:to, 1,1)}
      editor.indent
      editor.cursor.should == [1,3]
    end

    it "moves the cursor when selecting backward" do
      write("a\nb\nc\n")
      editor.move(:to, 1,1)
      editor.selecting{move(:to, 0,1)}
      editor.indent
      editor.cursor.should == [0,3]
    end

    it "marks as modified" do
      editor.selecting{move(:to, 0,1)}
      editor.indent
      editor.modified?.should == true
    end
  end

  describe :unindent do
    it "unindents single lines" do
      write("   a\n\n")
      editor.unindent
      editor.view.should == " a\n\n"
    end

    it "unindents single lines by one" do
      write(" a\n\n")
      editor.unindent
      editor.view.should == "a\n\n"
    end

    it "does not unindents single lines when not unindentable" do
      write("a\n\n")
      editor.unindent
      editor.view.should == "a\n\n"
    end

    it "move the cursor when unindenting single line" do
      write(" a\n\n")
      editor.move(:to, 0,1)
      editor.unindent
      editor.cursor.should == [0,0]
    end

    it "unindents selected lines" do
      write("a\n b\n   c")
      editor.selecting{ move(:to, 2,1) }
      editor.unindent
      editor.view.should == "a\nb\n c"
    end

    it "moves the selection" do
      write("   abcd\n b\n   c")
      editor.move(:to, 0,3)
      editor.selecting{ move(:to, 2,1) }
      editor.unindent
      editor.selection.should == ([0,1]..[2,0])
    end

    it "moves the selection when unindenting one space" do
      write(" abcd\n b\n   c")
      editor.move(:to, 0,3)
      editor.selecting{ move(:to, 2,1) }
      editor.unindent
      editor.selection.should == ([0,2]..[2,0])
    end

    it "does not move the selection when unindent is not possible" do
      write("abcd\n b\n   c")
      editor.move(:to, 0,3)
      editor.selecting{ move(:to, 2,1) }
      editor.unindent
      editor.selection.should == ([0,3]..[2,0])
    end

    it "moves the cursor when selecting forward" do
      write("\n abcd\n")
      editor.selecting{ move(:to, 1,3) }
      editor.unindent
      editor.cursor.should == [1,2]
    end

    it "moves the cursor when selecting backward" do
      write(" x\n  abcd\n")
      editor.move(:to, 1,3)
      editor.selecting{ move(:to, 0,1) }
      editor.unindent
      editor.cursor.should == [0,0]
    end
  end

  describe 'history' do
    it "does not overwrite the initial state" do
      write("a")
      editor.insert("b")
      editor.view # trigger save point
      stack = editor.history.stack
      stack.length.should == 2
      stack[0][:state][:content].should == "a"
      stack[1][:state][:content].should == "ba"

      editor.undo
      editor.history.position.should == 0

      editor.insert("c")
      editor.view # trigger save point
      stack.length.should == 2
      stack[0][:state][:content].should == "a"
      stack[1][:state][:content].should == "ca"
    end

    it "can undo an action" do
      write("a")
      editor.insert("b")
      editor.view # trigger save point
      future = Time.now + 10
      Time.stub(:now).and_return future
      editor.insert("c")
      editor.view # trigger save point
      editor.undo
      editor.view.should == "ba\n\n"
      editor.cursor.should == [0,1]
    end

    it "removes selection on undo" do
      editor.insert('a')
      editor.view # trigger save point
      editor.selecting{move(:to, 1,1)}
      editor.selection.should_not == nil
      editor.view # trigger save point
      editor.undo
      editor.selection.should == nil
    end

    it "sets modified on undo" do
      editor.insert('a')
      editor.save
      editor.modified?.should == false
      editor.undo
      editor.modified?.should == true
    end
  end

  describe :save do
    it 'stores the file' do
      write('xxx')
      editor.insert('a')
      editor.save.should == true
      File.binary_read(@file).should == 'axxx'
    end

    it 'creates the file' do
      `rm #{@file}`
      editor.insert('a')
      editor.save.should == true
      File.binary_read(@file).should == 'a'
    end

    it 'does not crash when it cannot save a file' do
      begin
        `chmod -w #{@file}`
        editor.save.should == "Permission denied - #{@file}"
      ensure
        `chmod +w #{@file}`
      end
    end

    describe 'remove trailing whitespace' do
      it "can remove trailing whitespace" do
        write("a  \n  \nb\n\n")
        editor.move(:to, 0,2)
        editor.instance_eval{@options[:remove_trailing_whitespace_on_save] = true}
        editor.save
        editor.view.should == "a\n\nb"
        editor.cursor.should == [0,1]
      end

      it "does not affect trailing newlines" do
        write("\n\n\n")
        editor.move(:to, 2,0)
        editor.instance_eval{@options[:remove_trailing_whitespace_on_save] = true}
        editor.save
        editor.view.should == "\n\n"
        editor.cursor.should == [2,0]
      end

      it "does not remove trailing whitespace by default" do
        write("a  \n  \nb\n\n")
        editor.save
        editor.view.should == "a  \n  \nb"
        editor.cursor.should == [0,0]
      end
    end
  end

  describe :delete do
    it 'removes a char' do
      write('123')
      editor.delete(1)
      editor.view.should == "23\n\n"
      editor.cursor.should == [0,0]
    end

    it 'removes a line' do
      write("123\n45")
      editor.move(:relative, 0,3)
      editor.delete(1)
      editor.view.should == "12345\n\n"
      editor.cursor.should == [0,3]
    end

    it "cannot backspace over 0,0" do
      write("aa")
      editor.move(:relative, 0,1)
      editor.delete(-3)
      editor.view.should == "a\n\n"
      editor.cursor.should == [0,0]
    end

    it 'backspaces a char' do
      write('123')
      editor.move(:relative, 0,3)
      editor.delete(-1)
      editor.view.should == "12\n\n"
      editor.cursor.should == [0,2]
    end

    it 'backspaces a newline' do
      write("1\n234")
      editor.move(:relative, 1,0)
      editor.delete(-1)
      editor.view.should == "1234\n\n"
      editor.cursor.should == [0,1]
    end
  end

  describe :modified? do
    it "is unchanged by default" do
      editor.modified?.should == false
    end

    it "is changed after insert" do
      editor.insert('x')
      editor.modified?.should == true
    end

    it "is changed after delete" do
      write("abc")
      editor.delete(1)
      editor.modified?.should == true
    end

    it "is not changed after move" do
      editor.move(:relative, 1,1)
      editor.modified?.should == false
    end

    it "is unchanged after save" do
      editor.insert('x')
      editor.save
      editor.modified?.should == false
    end

    it "is changed after delete_line" do
      write("\n\n\n")
      editor.delete_line
      editor.modified?.should == true
    end
  end

  describe :find do
    before do
      write("\n ab\n ab")
    end

    it "moves to first occurrence" do
      editor.find('ab')
      editor.cursor.should == [1,1]
    end

    it "moves to next occurrence" do
      editor.move(:relative, 1,1)
      editor.find('ab')
      editor.cursor.should == [2,1]
    end

    it "stays in place when nothing was found" do
      editor.move(:relative, 2,1)
      editor.find('ab')
      editor.cursor.should == [2,1]
    end

    it "selects the occurrence" do
      editor.find('ab')
      editor.selection.should == ([1, 1]..[1, 3])
    end
  end

  describe :delete_line do
    before do
      write("1\nlonger_than_columns\n56789")
    end

    it "removes the current line from first char" do
      editor.move(:to, 1, 0)
      editor.delete_line
      editor.view.should == "1\n56789\n"
      editor.cursor.should == [1, 0]
    end

    it "removes the current line from last char" do
      editor.move(:to, 1, 3)
      editor.delete_line
      editor.view.should == "1\n56789\n"
      editor.cursor.should == [1, 3]
    end

    it "can remove the first line" do
      editor.delete_line
      editor.view.should == "longe\n56789\n"
      editor.cursor.should == [0, 0]
    end

    it "can remove the last line" do
      write("aaa")
      editor.delete_line
      editor.view.should == "\n\n"
      editor.cursor.should == [0, 0]
    end

    it "can remove the last line with lines remaining" do
      write("aaa\nbbb")
      editor.move(:to, 1,1)
      editor.delete_line
      editor.view.should == "aaa\n\n"
      editor.cursor.should == [0, 1]
    end

    it "jumps to end of next lines end when put of space" do
      write("1\n234\n5")
      editor.move(:to, 1, 3)
      editor.delete_line
      editor.cursor.should == [1, 1]
    end

    it "can remove lines outside of initial screen" do
      write("0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n")
      editor.move(:to, 5, 0)
      editor.move(:to, 6, 1)
      editor.delete_line
      editor.view.should == "5\n7\n8"
      editor.cursor.should == [1, 1]
    end

    it "can remove the last line" do
      write('xxx')
      editor.delete_line
      editor.insert('yyy')
      editor.view.should == "yyy\n\n"
    end
  end

  describe 'with line_numbers' do
    let(:editor){ Ruco::Editor.new(@file, :lines => 5, :columns => 10, :line_numbers => true) }

    before do
      write("a\nb\nc\nd\ne\nf\ng\nh\n")
    end

    it "adds numbers to view" do
      editor.view.should == "   1 a\n   2 b\n   3 c\n   4 d\n   5 e"
    end

    it "does not show numbers for empty lines" do
      editor.move(:to, 10,0)
      editor.view.should == "   6 f\n   7 g\n   8 h\n   9 \n     "
    end

    it "adjusts the cursor" do
      editor.cursor.should == [0,5]
    end

    it "adjusts the style map" do
      editor.selecting{ move(:to, 0,1) }
      editor.style_map.flatten.should == [
        [nil, nil, nil, nil, nil, :reverse, nil, :normal],
        nil, nil, nil, nil
      ]
    end
  end
end
