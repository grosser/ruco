require File.expand_path('spec/spec_helper')

describe Ruco::CommandBar do
  let(:bar){ Ruco::CommandBar.new(:columns => 30) }

  it "shows shortcuts by default" do
    bar.view.should == "^W Exit    ^S Save    ^F Find"
  end

  it "shows less shortcuts when space is low" do
    bar = Ruco::CommandBar.new(:columns => 29)
    bar.view.should == "^W Exit    ^S Save    ^F Find"
    bar = Ruco::CommandBar.new(:columns => 28)
    bar.view.should == "^W Exit    ^S Save"
  end

  describe :find do
    it "sets command bar into search mode" do
      bar.find
      bar.view.should == "Find: "
      bar.cursor_column.should == 6
    end

    it "can enter stuff" do
      bar.find
      bar.insert('abc')
      bar.view.should == "Find: abc"
      bar.cursor_column.should == 9
    end

    it "can reset the search" do
      bar.find
      bar.insert('abc')
      bar.insert("\n")
      bar.reset

      bar.view.should include("^W Exit ") # default view
      bar.find
      bar.view.should == "Find: " # term removed
    end

    it "can execute a search" do
      bar.find
      bar.insert('abc')
      result = bar.insert("d\n")
      result.should == Ruco::Command.new(:find, 'abcd')
    end

    it "finds with offset when same search is entered again" do
      bar.find
      bar.insert('abcd')
      bar.insert("\n")
      result = bar.insert("\n")
      result.should == Ruco::Command.new(:find, 'abcd')
    end
  end
end