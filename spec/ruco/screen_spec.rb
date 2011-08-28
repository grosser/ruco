require File.expand_path('spec/spec_helper')

describe Ruco::Screen do
  describe :curses_style do
    it "is 'normal' for nothing" do
      Ruco::Screen.curses_style(:normal).should == Curses::A_NORMAL
    end

    it "is red for red" do
      pending
      Ruco::Screen.curses_style(:red).should == Curses::color_pair( Curses::COLOR_RED )
    end

    it "is reverse for reverse" do
      Ruco::Screen.curses_style(:reverse).should == Curses::A_REVERSE
    end

    it "raises on unknown style" do
      lambda{
        Ruco::Screen.curses_style(:foo)
      }.should raise_error
    end
  end
end
