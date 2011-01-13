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
end