# encoding: UTF-8
require File.expand_path('spec/spec_helper')

describe Ruco::Application do
  before do
    @file = 'spec/temp.txt'
    write('')
  end

  def write(content)
    File.open(@file,'w'){|f| f.write(content) }
  end

  def editor_part(view)
    view.naive_split("\n")[1..-2].join("\n")
  end

  let(:app){ Ruco::Application.new(@file, :lines => 5, :columns => 10) }
  let(:status){ "Ruco #{Ruco::VERSION} -- spec/temp.txt  \n" }
  let(:command){ "^W Exit" }

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
    app.view.should == "#{status.sub('.txt ','.txt*')}22\n2\n\n#{command}"
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
    app.view.should == "#{status}123\n456\n789\n#{command}"
    app.cursor.should == [2,0] # 0 offset + 1 for statusbar
  end

  it "can resize" do
    write("01234567\n1\n2\n3\n4\n5678910111213\n6\n7\n8")
    app.resize(8, 7)
    app.view.should == "#{status}0123456\n1\n2\n3\n4\n5678910\n6\n7\n#{command}"
  end

  describe 'closing' do
    it "can quit" do
      result = app.key(:"Ctrl+w")
      result.should == :quit
    end

    it "asks before closing changed file -- escape == no" do
      app.key('a')
      app.key(:"Ctrl+w")
      app.view.split("\n").last.should include("Loose changes")
      app.key(:escape).should_not == :quit
      app.key("\n").should_not == :quit
    end

    it "asks before closing changed file -- enter == yes" do
      app.key('a')
      app.key(:"Ctrl+w")
      app.view.split("\n").last.should include("Loose changes")
      app.key(:enter).should == :quit
    end
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
      editor_part(app.view).should == "    ab\n  cd\n  ef"
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

    it "does not indent when inside line and next line has more whitespace" do
      write("ab\n  b\n")
      app.key(:right)
      app.key(:enter)
      app.key('c')
      editor_part(app.view).should == "a\ncb\n  b"
    end
  end

  describe '.ruco.rb' do
    it "loads it and can use the bound keys" do
      Tempfile.string_as_file("Ruco.configure{ bind(:'Ctrl+e'){ @editor.insert('TEST') } }") do |file|
        File.stub!(:exist?).and_return true
        File.should_receive(:expand_path).with("~/.ruco.rb").and_return file
        app.view.should_not include('TEST')
        app.key(:"Ctrl+e")
        app.view.should include("TEST")
      end
    end
  end
end