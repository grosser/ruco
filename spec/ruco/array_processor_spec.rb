require File.expand_path('spec/spec_helper')

describe Ruco::ArrayProcessor do
  let(:p){ Ruco::ArrayProcessor.new }
  before do
    p.new_line('xxx')
  end

  it "is empty by default" do
    p.lines.should == [[]]
  end

  it "parses simple syntax" do
    p.open_tag('xxx',0)
    p.close_tag('xxx',3)
    p.lines.should == [[['xxx',0...3]]]
  end

  it "parses nested syntax" do
    p.open_tag('xxx',0)
    p.open_tag('yyy',2)
    p.close_tag('yyy',3)
    p.close_tag('xxx',3)
    p.lines.should == [[["yyy", 2...3], ["xxx", 0...3]]]
  end

  it "parses multiline syntax" do
    p.open_tag('xxx',0)
    p.close_tag('xxx',3)
    p.new_line('xxx')
    p.open_tag('xxx',1)
    p.close_tag('xxx',2)
    p.lines.should == [
      [["xxx", 0...3]],
      [["xxx", 1...2]]
    ]
  end

  it "parses multiply nested syntax" do
    p.open_tag('yyy',0)
    p.open_tag('yyy',2)
    p.close_tag('yyy',3)
    p.close_tag('yyy',3)
    p.lines.should == [[["yyy", 2...3], ["yyy", 0...3]]]
  end
end
