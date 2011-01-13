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
    app.cursor.should == [3,0] # 0 offset + 1 for statusbar
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
end