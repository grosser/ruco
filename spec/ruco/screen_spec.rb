require File.expand_path('spec/spec_helper')

describe Ruco::Screen do
  describe :curses_style do
    it "is 'normal' for nothing" do
      Ruco::Screen.curses_style(:normal).should == 256
    end

    it "is red for red" do
      pending
      Ruco::Screen.curses_style(:red).should == Curses::color_pair( Curses::COLOR_RED )
    end

    it "is reverse for reverse" do
      Ruco::Screen.curses_style(:reverse).should == 512
    end

    it "raises on unknown style" do
      lambda{
        Ruco::Screen.curses_style(:foo)
      }.should raise_error
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
