require File.expand_path('spec/spec_helper')

describe Ruco::Application do
  before do
    @file = 'spec/temp.txt'
  end

  def write(content)
    File.open(@file,'w'){|f| f.write(content) }
  end

  let(:app){ Ruco::Application.new(@file, :lines => 5, :columns => 10) }
  let(:status){ "Ruco #{Ruco::VERSION} -- spec/temp.txt  \n" }
  let(:command){ "^W Exit" }

  it "renders status + editor + command" do
    write("xxx\nyyy\nzzz")
    app.view.should == "#{status}xxx\nyyy\nzzz\n#{command}"
  end

  it "can enter stuff" do
    write("")
    app.key(50)
    app.key(50)
    app.key(:enter)
    app.key(50)
    app.key(:enter)
    app.view.should == "#{status.sub('.txt ','.txt*')}22\n2\n\n#{command}"
  end

  it "can execute a command" do
    write("123\n456\n789\n")
    app.key(:"Ctrl+g") # go to line
    app.key(50) # 2
    app.key(:enter)
    app.view.should == "#{status}123\n456\n789\n#{command}"
    app.cursor.should == [2,0] # 0 offset + 1 for statusbar
  end

  describe 'closing' do
    it "can quit" do
      result = app.key(:"Ctrl+w")
      result.should == :quit
    end

    it "asks before closing changed file -- escape == no" do
      app.key(?a.ord)
      app.key(:"Ctrl+w")
      app.view.split("\n").last.should include("Loose changes")
      app.key(:escape).should_not == :quit
      app.key("\n").should_not == :quit
    end

    it "asks before closing changed file -- enter == yes" do
      app.key(?a.ord)
      app.key(:"Ctrl+w")
      app.view.split("\n").last.should include("Loose changes")
      app.key(:enter).should == :quit
    end
  end

  describe 'go to line' do
    it "goes to the line" do
      app.key(:"Ctrl+g")
      app.key(?2.ord)
      app.key(:enter)
      app.cursor.should == [2,0] # status bar +  2
    end

    it "goes to 1 when strange stuff entered" do
      app.key(:"Ctrl+g")
      app.key(?0.ord)
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