# encoding: UTF-8
require File.expand_path('spec/spec_helper')

describe Ruco::Application do
  before do
    `rm -rf ~/.ruco/sessions`
    `rm #{rucorc} 2>&1`
    @file = 'spec/temp.txt'
    write('')
  end

  after do
    `rm #{rucorc} 2>&1`
    `rm -f #{@file}`
  end

  def write(content)
    File.open(@file,'wb'){|f| f.write(content) }
  end

  def read
    File.binary_read(@file)
  end

  def editor_part(view)
    view.naive_split("\n")[1..-2].join("\n")
  end

  def type(*keys)
    keys.each{|k| app.key k }
  end

  def status(line=1)
    "Ruco #{Ruco::VERSION} -- spec/temp.txt                    #{line}:1\n"
  end

  let(:rucorc){ 'spec/.ruco.rb' }
  let(:app){ Ruco::Application.new(@file, :lines => 5, :columns => 50, :rc => rucorc) }
  let(:command){ "^W Exit    ^S Save    ^F Find    ^R Replace" }

  it "renders status + editor + command" do
    write("xxx\nyyy\nzzz")
    app.view.should == "#{status}xxx\nyyy\nzzz\n#{command}"
  end

  it "can enter stuff" do
    app.key('2')
    app.key('2')
    app.key(:enter)
    app.key('2')
    app.key(:enter)
    app.view.should == "#{status(3).sub('.txt ','.txt*')}2\n\n\n#{command}"
  end

  it "does not enter key-codes" do
    app.key(888)
    app.view.should == "#{status}\n\n\n#{command}"
  end

  it "can execute a command" do
    write("123\n456\n789\n")
    app.key(:"Ctrl+g") # go to line
    app.key('2') # 2
    app.key(:enter)
    app.view.should == "#{status(2)}123\n456\n789\n#{command}"
    app.cursor.should == [2,0] # 0 offset + 1 for statusbar
  end

  it "can resize" do
    write("01234567\n1\n2\n3\n4\n5678910111213\n6\n7\n8")
    app.resize(8, 7)
    app.view.should == "Ruco 0.\n0123456\n1\n2\n3\n4\n5678910\n^W Exit"
  end

  describe 'opening with line' do
    before do
      write("\n1\n2\n3\n4\n5\n")
      @file = @file+":2"
    end

    it "opens file at given line" do
      app.cursor.should == [2,0]
      app.view.should_not include(@file)
    end

    it "can save when opening with line" do
      type 'a', :"Ctrl+s"
      @file = @file[0..-3]
      read.should == "\na1\n2\n3\n4\n5\n"
    end

    it "opens file with : if file with : exist" do
      write("\n1\n2\n3\n4\n5\n")
      app.view.should include(@file)
    end

    it "opens file with : if file with and without : do not exist" do
      @file[-2..-1] = 'xxx:5'
      app.cursor.should == [1,0]
      app.view.should include(@file)
    end
  end

  describe 'closing' do
    it "can quit" do
      result = app.key(:"Ctrl+w")
      result.should == :quit
    end

    it "asks before closing changed file -- escape == no" do
      app.key('a')
      app.key(:"Ctrl+w")
      app.view.split("\n").last.should include("Lose changes")
      app.key(:escape).should_not == :quit
      app.key("\n").should_not == :quit
    end

    it "asks before closing changed file -- enter == yes" do
      app.key('a')
      app.key(:"Ctrl+w")
      app.view.split("\n").last.should include("Lose changes")
      app.key(:enter).should == :quit
    end
  end

  describe 'session' do
    it "stores the session so I can reopen at the same position" do
      write("0\n1\n2\n")
      type :right, :down, :"Ctrl+q"
      reopened = Ruco::Application.new(@file, :lines => 5, :columns => 10, :rc => rucorc)
      reopened.cursor.should == [2,1]
    end

    it "does not store or restore content" do
      write('')
      type 'x', :"Ctrl+s", :enter, :enter, 'a', :"Ctrl+q"
      reopened = Ruco::Application.new(@file, :lines => 5, :columns => 10, :rc => rucorc)
      editor_part(reopened.view).should == "x\n\n"
    end
  end

  it "can select all" do
    write("1\n2\n3\n4\n5\n")
    app.key(:down)
    app.key(:"Ctrl+a")
    app.key(:delete)
    app.view.should include("\n\n\n")
  end

  describe 'go to line' do
    it "goes to the line" do
      write("\n\n\n")
      app.key(:"Ctrl+g")
      app.key('2')
      app.key(:enter)
      app.cursor.should == [2,0] # status bar +  2
    end

    it "goes to 1 when strange stuff entered" do
      write("\n\n\n")
      app.key(:"Ctrl+g")
      app.key('0')
      app.key(:enter)
      app.cursor.should == [1,0] # status bar +  1
    end
  end

  describe 'insert hash rocket' do
    it "inserts an amazing hash rocket" do
      write("")
      app.key(:"Ctrl+l")
      editor_part(app.view).should == " => \n\n"
    end
  end

  describe 'Find and replace' do
    it "stops when nothing is found" do
      write 'abc'
      type :"Ctrl+r", 'x', :enter
      app.view.should_not include("Replace with:")
    end

    it "can find and replace multiple times" do
      write 'xabac'
      type :"Ctrl+r", 'a', :enter
      app.view.should include("Replace with:")
      type 'd', :enter
      app.view.should include("Replace=Enter")
      type :enter # replace first
      app.view.should include("Replace=Enter")
      type :enter # replace second -> finished
      app.view.should_not include("Replace=Enter")
      editor_part(app.view).should == "xdbdc\n\n"
    end

    it "can find and skip replace multiple times" do
      write 'xabac'
      type :"Ctrl+r", 'a', :enter
      app.view.should include("Replace with:")
      type 'd', :enter
      app.view.should include("Replace=Enter")
      type 's' # skip
      app.view.should include("Replace=Enter")
      type 's' # skip
      app.view.should_not include("Replace=Enter")
      editor_part(app.view).should == "xabac\n\n"
    end

    it "can replace all" do
      write '_a_a_a_a'
      type :"Ctrl+r", 'a', :enter
      app.view.should include("Replace with:")
      type 'd', :enter
      app.view.should include("Replace=Enter")
      type 's' # skip first
      app.view.should include("Replace=Enter")
      type 'a' # all
      app.view.should_not include("Replace=Enter")
      editor_part(app.view).should == "_a_d_d_d\n\n"
    end

    it "breaks if neither s nor enter is entered" do
      write 'xabac'
      type :"Ctrl+r", 'a', :enter
      app.view.should include("Replace with:")
      type "d", :enter
      app.view.should include("Replace=Enter")
      type 'x' # stupid user
      app.view.should_not include("Replace=Enter")
      editor_part(app.view).should == "xabac\n\n"
    end

    it "reuses find" do
      write 'xabac'
      type :"Ctrl+f", 'a', :enter
      type :"Ctrl+r"
      app.view.should include("Find: a")
      type :enter
      app.view.should include("Replace with:")
    end
  end

  describe :bind do
    it "can execute bound stuff" do
      test = 0
      app.bind :'Ctrl+q' do
        test = 1
      end
      app.key(:'Ctrl+q')
      test.should == 1
    end

    it "can execute an action via bind" do
      test = 0
      app.action :foo do
        test = 1
      end
      app.bind :'Ctrl+q', :foo
      app.key(:'Ctrl+q')
      test.should == 1
    end
  end

  describe 'indentation' do
    it "does not extra-indent when pasting" do
      Ruco.class_eval "Clipboard.copy('ab\n  cd\n  ef')"
      app.key(:tab)
      app.key(:tab)
      app.key(:'Ctrl+v') # paste
      editor_part(app.view).should == "  cd\n  ef\n"
    end

    it "indents when typing" do
      app.key(:tab)
      app.key(:tab)
      app.key(:enter)
      app.key('a')
      editor_part(app.view).should == "    \n    a\n"
    end

    it "indents when at end of line and the next line has more whitespace" do
      write("a\n  b\n")
      app.key(:right)
      app.key(:enter)
      app.key('c')
      editor_part(app.view).should == "a\n  c\n  b"
    end

    it "indents when inside line and next line has more whitespace" do
      write("ab\n  b\n")
      type :right, :enter, 'c'
      editor_part(app.view).should == "a\n  cb\n  b"
    end

    it "indents when inside indented line" do
      write("  ab\nc\n")
      type :right, :right, :right, :enter, 'd'
      editor_part(app.view).should == "  a\n  db\nc"
    end

    it "indents when tabbing on selection" do
      write("ab")
      app.key(:"Shift+right")
      app.key(:tab)
      editor_part(app.view).should == "  ab\n\n"
    end

    it "unindents on Shift+tab" do
      write("  ab\n  cd\n")
      app.key(:"Shift+tab")
      editor_part(app.view).should == "ab\n  cd\n"
    end
  end

  describe '.ruco.rb' do
    it "loads it and can use the bound keys" do
      File.write(rucorc, "Ruco.configure{ bind(:'Ctrl+e'){ @editor.insert('TEST') } }")
      app.view.should_not include('TEST')
      app.key(:"Ctrl+e")
      app.view.should include("TEST")
    end

    it "uses settings" do
      File.write(rucorc, "Ruco.configure{ options.convert_tabs = true }")
      app.options[:convert_tabs].should == true
    end

    it "passes settings to the window" do
      File.write(rucorc, "Ruco.configure{ options.window_line_scroll_offset = 10 }")
      app.send(:editor).send(:text_area).instance_eval{@window}.instance_eval{@options[:line_scroll_offset]}.should == 10
    end

    it "passes settings to history" do
      File.write(rucorc, "Ruco.configure{ options.history_entries = 10 }")
      app.send(:editor).send(:text_area).instance_eval{@history}.instance_eval{@options[:entries]}.should == 10
    end
  end

  describe 'select mode' do
    it "turns move commands into select commands" do
      write('abc')
      type :'Ctrl+b', :right, :right, 'a'
      editor_part(app.view).should == "ac\n\n"
    end

    it "stops after first non-move command" do
      write('abc')
      type :'Ctrl+b', :right, 'd', :right, 'e'
      editor_part(app.view).should == "dbec\n\n"
    end

    it "stops after hitting twice" do
      write('abc')
      type :'Ctrl+b', :'Ctrl+b', :right, 'd'
      editor_part(app.view).should == "adbc\n\n"
    end
  end

  describe 'find' do
    it "finds" do
      write('text foo')
      type :'Ctrl+f', 'foo', :enter
      app.cursor.should == [1, 5]
    end

    it "shows a menu when nothing was found and there were previous matches" do
      write('text bar bar foo')
      type :'Ctrl+f', 'bar', :enter
      type :'Ctrl+f', 'bar', :enter
      type :'Ctrl+f', 'bar', :enter
      app.view.split("\n").last.should include("No matches found")
    end

    it "returns to top after no matches found" do
      write('text foo foo')
      type :'Ctrl+f', 'foo', :enter
      app.cursor.should == [1, 5]
      type :'Ctrl+f', 'foo', :enter
      app.cursor.should == [1, 9]
      type :'Ctrl+f', 'foo', :enter, :enter
      app.cursor.should == [1, 5]
    end

    it "notifies user when no matches are found in the entire document" do
      write('text foo')
      type :'Ctrl+f', 'bar', :enter
      app.view.split("\n").last.should include("No matches found in entire document")
    end


  end

  describe :save do
    it "just saves" do
      write('')
      app.key('x')
      app.key(:'Ctrl+s')
      read.should == 'x'
    end

    it "warns when saving failed" do
      begin
        `chmod -w #{@file}`
        app.key(:'Ctrl+s')
        app.view.should include('Permission denied')
        app.key(:enter) # retry ?
        app.view.should include('Permission denied')
        app.key(:escape)
        app.view.should_not include('Permission denied')
      ensure
        `chmod +w #{@file}`
      end
    end
  end
end
