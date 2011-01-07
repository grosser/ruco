require File.expand_path('spec/spec_helper')

describe Ruco do
  def write(content)
    File.open(@file,'w'){|f| f.write(content) }
  end

  it "has a VERSION" do
    Ruco::VERSION.should =~ /^\d+\.\d+\.\d+$/
  end

  describe 'viewing' do
    before do
      @file = 'spec/temp.txt'
      write('')
    end

    let(:editor){ Ruco::Editor.new(@file, :lines => 3, :columns => 5) }

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
end
