require File.expand_path('spec/spec_helper')

describe Ruco::Editor do
  def write(content)
    File.open(@file,'w'){|f| f.write(content) }
  end

  let(:editor){ Ruco::Editor.new(@file, :lines => 3, :columns => 5, :line_scrolling_offset => 5, :column_scrolling_offset => 5) }

  before do
    @file = 'spec/temp.txt'
  end

  describe "\\r" do
    it "raises on \r" do
      write("\r")
      lambda{editor}.should raise_error
    end
    
    it "raises on \r\n" do
      write("\r\n")
      lambda{editor}.should raise_error
    end
    
    it "is happy with \n" do
      write("\n")
      editor
    end
  end
  
  describe 'convert tabs' do
    before do
      write("\t\ta")
    end

    it "reads tab as spaces when option is set" do
      editor = Ruco::Editor.new(@file, :lines => 3, :columns => 5, :convert_tabs => true)
      editor.view.should == "    a\n\n\n"
    end

    it "reads them normally when option is not set" do
      editor = Ruco::Editor.new(@file, :lines => 3, :columns => 5)
      editor.view.should == "\t\ta\n\n\n"
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

    it "cannot move right of characters" do
      editor.move(:relative, 2,6)
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
        editor.view.should == "12345\n123\n\n"
        editor.cursor.column.should == 4

        editor.move(:relative, 0,1)
        editor.view.should == "45678\n\n\n"
        editor.cursor.column.should == 2
      end

      it "cannot scroll past the screen" do
        write('123456789')
        editor.move(:relative, 0,4)
        6.times{ editor.move(:relative, 0,1) }
        editor.view.should == "89\n\n\n"
        editor.cursor.column.should == 2
      end

      it "can scroll columns backwards" do
        write('123456789')
        editor.move(:relative, 0,5)
        editor.view.should == "45678\n\n\n"

        editor.move(:relative, 0,-3)
        editor.view.should == "12345\n\n\n"
        editor.cursor.column.should == 2
      end
    end

    describe 'line scrolling' do
      before do
        write("1\n2\n3\n4\n5\n6\n7\n8\n9")
      end

      it "can scroll lines down" do
        editor.move(:relative, 2,0)
        editor.view.should == "1\n2\n3\n"

        editor.move(:relative, 1,0)
        editor.view.should == "3\n4\n5\n"
        editor.cursor.line.should == 1
      end

      it "can scroll till end of file" do
        editor.move(:relative, 15,0)
        editor.view.should == "8\n9\n\n"
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
      editor.view.should == "X4567\n\n\n"
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
      editor.view.should == "1X6\n789\n\n"
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
      editor.view.should == "16\n789\n\n"
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

  describe :color_mask do
    it "is empty by default" do
      editor.color_mask.should == [nil,nil,nil]
    end

    it "shows one-line selection" do
      write('12345678')
      editor.selecting do
        move(:to, 0, 4)
      end
      editor.color_mask.should == [
        [[0,262144],[4,0]],
        nil,
        nil,
      ]
    end

    it "shows multi-line selection" do
      write("012\n345\n678")
      editor.move(:to, 0,1)
      editor.selecting do
        move(:to, 1, 1)
      end
      editor.color_mask.should == [
        [[1,262144],[5,0]],
        [[0,262144],[1,0]],
        nil,
      ]
    end

    it "shows the selection from offset" do
      write('12345678')
      editor.move(:to, 0, 2)
      editor.selecting do
        move(:to, 0, 4)
      end
      editor.color_mask.should == [
        [[2,262144], [4,0]],
        nil,
        nil,
      ]
    end

    it "shows the selection in nth line" do
      write("\n12345678")
      editor.move(:to, 1, 2)
      editor.selecting do
        move(:to, 1, 4)
      end
      editor.color_mask.should == [
        nil,
        [[2,262144], [4,0]],
        nil,
      ]
    end

    it "shows multi-line selection in scrolled space" do
      write("\n\n\n\n\n0123456789\n0123456789\n0123456789\n\n")
      ta = editor.send(:text_area)
      ta.send(:position=, [5,8])
      ta.send(:screen_position=, [5,7])
      editor.selecting do
        move(:relative, 2, 1)
      end
      editor.view.should == "789\n789\n789\n"
      editor.cursor.should == [2,2]
      editor.color_mask.should == [
        [[1,262144],[5,0]], # start to end of screen
        [[0,262144],[5,0]], # 0 to end of screen
        [[0,262144],[2,0]], # 0 to end of selection
      ]
    end
  end

  describe :view do
    before do
      write('')
    end

    it "displays an empty screen" do
      editor.view.should == "\n\n\n"
    end

    it "displays short file content" do
      write('xxx')
      editor.view.should == "xxx\n\n\n"
    end

    it "displays long file content" do
      write('1234567')
      editor.view.should == "12345\n\n\n"
    end

    it "displays multiline-file content" do
      write("xxx\nyyy\nzzz\niii")
      editor.view.should == "xxx\nyyy\nzzz\n"
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
      editor.view.should == "1ab23\n\n\n"
      editor.cursor.should == [0,3]
    end

    it "can insert new newlines" do
      editor.insert("ab\nc")
      editor.view.should == "ab\nc\n\n"
      editor.cursor.should == [1,1]
    end

    it "jumps to correct column when inserting newline" do
      write("abc\ndefg")
      editor.move(:relative, 1,2)
      editor.insert("1\n23")
      editor.view.should == "abc\nde1\n23fg\n"
      editor.cursor.should == [2,2]
    end

    it "jumps to correct column when inserting 1 newline" do
      write("abc\ndefg")
      editor.move(:relative, 1,2)
      editor.insert("\n")
      editor.view.should == "abc\nde\nfg\n"
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
      editor.view.should == "  \n\n\n"
      editor.cursor.should == [0,2]
    end
  end

  describe :indent do
    it "indents selected lines" do
      write("a\nb\nc\n")
      editor.selecting{move(:to, 1,1)}
      editor.indent
      editor.view.should == "  a\n  b\nc\n"
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
      editor.view.should == " a\n\n\n"
    end

    it "unindents single lines by one" do
      write(" a\n\n")
      editor.unindent
      editor.view.should == "a\n\n\n"
    end

    it "does not unindents single lines when not unindentable" do
      write("a\n\n")
      editor.unindent
      editor.view.should == "a\n\n\n"
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
      editor.view.should == "a\nb\n c\n"
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
    it "can undo an action" do
      write("a")
      editor.insert("b")
      editor.view # trigger save point
      future = Time.now + 10
      Time.stub!(:now).and_return future
      editor.insert("c")
      editor.view # trigger save point
      editor.undo
      editor.view.should == "ba\n\n\n"
      editor.cursor.should == [0,1]
    end

    it "removes selection on undo" do
      editor.insert('a')
      editor.selecting{move(:to, 1,1)}
      editor.selection.should_not == nil
      editor.view # trigger save point
      editor.undo
      editor.selection.should == nil
    end

    it "sets modified on undo" do
      editor.insert('a')
      editor.view # trigger save point
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
      File.read(@file).should == 'axxx'
    end

    it 'creates the file' do
      `rm #{@file}`
      editor.insert('a')
      editor.save.should == true
      File.read(@file).should == 'a'
    end

    it 'does not crash when it cannot save a file' do
      begin
        `chmod -w #{@file}`
        editor.save.should == "Permission denied - #{@file}"
      ensure
        `chmod +w #{@file}`
      end
    end
  end

  describe :delete do
    it 'removes a char' do
      write('123')
      editor.delete(1)
      editor.view.should == "23\n\n\n"
      editor.cursor.should == [0,0]
    end

    it 'removes a line' do
      write("123\n45")
      editor.move(:relative, 0,3)
      editor.delete(1)
      editor.view.should == "12345\n\n\n"
      editor.cursor.should == [0,3]
    end

    it "cannot backspace over 0,0" do
      write("aa")
      editor.move(:relative, 0,1)
      editor.delete(-3)
      editor.view.should == "a\n\n\n"
      editor.cursor.should == [0,0]
    end

    it 'backspaces a char' do
      write('123')
      editor.move(:relative, 0,3)
      editor.delete(-1)
      editor.view.should == "12\n\n\n"
      editor.cursor.should == [0,2]
    end

    it 'backspaces a newline' do
      write("1\n234")
      editor.move(:relative, 1,0)
      editor.delete(-1)
      editor.view.should == "1234\n\n\n"
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
      editor.view.should == "1\n56789\n\n"
      editor.cursor.should == [1, 0]
    end

    it "removes the current line from last char" do
      editor.move(:to, 1, 3)
      editor.delete_line
      editor.view.should == "1\n56789\n\n"
      editor.cursor.should == [1, 3]
    end

    it "can remove the first line" do
      editor.delete_line
      editor.view.should == "longe\n56789\n\n"
      editor.cursor.should == [0, 0]
    end

    it "can remove the last line" do
      write("aaa")
      editor.delete_line
      editor.view.should == "\n\n\n"
      editor.cursor.should == [0, 0]
    end

    it "can remove the last line with lines remaining" do
      write("aaa\nbbb")
      editor.move(:to, 1,1)
      editor.delete_line
      editor.view.should == "aaa\n\n\n"
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
      editor.view.should == "5\n7\n8\n"
      editor.cursor.should == [1, 1]
    end

    it "can remove the last line" do
      write('xxx')
      editor.delete_line
      editor.insert('yyy')
      editor.view.should == "yyy\n\n\n"
    end
  end
end