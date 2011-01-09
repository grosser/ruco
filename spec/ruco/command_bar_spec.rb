require File.expand_path('spec/spec_helper')

describe Ruco::CommandBar do
  let(:editor){ Ruco::Editor.new('spec/temp.txt', :columns => 10, :lines => 5) }
  let(:bar){ Ruco::CommandBar.new(editor, :columns => 30) }

  it "shows shortcuts by default" do
    bar.view.should == "^W Exit -- ^S Save -- ^F Find"
  end

  it "shows less shortcuts when space is low" do
    bar = Ruco::CommandBar.new(editor, :columns => 29)
    bar.view.should == "^W Exit -- ^S Save -- ^F Find"
    bar = Ruco::CommandBar.new(editor, :columns => 28)
    bar.view.should == "^W Exit -- ^S Save"
  end
end