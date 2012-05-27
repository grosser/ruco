require "spec_helper"

describe Ruco::Screen do
  describe :curses_style do
    it "is 'normal' for nothing" do
      Ruco::Screen.curses_style(:normal, true).should == 256
    end

    it "is red for red" do
      pending
      Ruco::Screen.curses_style(:red, true).should == Curses::color_pair( Curses::COLOR_RED )
    end

    it "is reverse for reverse" do
      Ruco::Screen.curses_style(:reverse, true).should == 512
    end

    it "raises on unknown style" do
      lambda{
        Ruco::Screen.curses_style(:foo, true)
      }.should raise_error
    end

    describe 'without colors' do
      it "is 'normal' for normal" do
        Ruco::Screen.curses_style(:normal, false).should == Curses::A_NORMAL
      end

      it "is reverse for reverse" do
        Ruco::Screen.curses_style(:reverse, false).should == Curses::A_REVERSE
      end

      it "is normal for unknown style" do
        Ruco::Screen.curses_style(:foo, false).should == Curses::A_NORMAL
      end
    end
  end

  describe :html_to_terminal_color do
    # http://www.mudpedia.org/wiki/Xterm_256_colors
    [
      ['#ff0000', 196],
      ['#00ff00', 46],
      ['#0000ff', 21],
      ['#ffffff', 231]
    ].each do |html,term|
      it "converts #{html} to #{term}" do
        Ruco::Screen.html_to_terminal_color(html).should == term
      end
    end
  end
end
