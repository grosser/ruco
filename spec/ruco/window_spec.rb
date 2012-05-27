require "spec_helper"

describe Ruco::Window do
  let(:window){ Ruco::Window.new(10,10) }

  describe :crop do
    let(:window){
      Ruco::Window.new(2,4,
        :line_scroll_threshold => 0, :line_scroll_offset => 1,
        :column_scroll_threshold => 0, :column_scroll_offset => 1
      )
    }

    it "does not modify given lines" do
      original = ['1234','1234']
      window.crop(original)
      original.should == ['1234','1234']
    end

    it "removes un-displayable chars" do
      result = window.crop(['12345','12345','12345'])
      result.should == ['1234','1234']
    end

    it "does not add whitespace" do
      result = window.crop(['1','',''])
      result.should == ['1','']
    end

    it "creates lines if necessary" do
      result = window.crop(['1234'])
      result.should == ['1234','']
    end

    it "stays inside frame as long as position is in frame" do
      window.position = Ruco::Position.new(1,3)
      result = window.crop(['12345678','12345678'])
      result.should == ['1234','1234']
    end

    it "can display empty lines" do
      window.crop([]).should == ['','']
    end

    describe 'scrolled' do
      it "goes out of frame if line is out of frame" do
        window = Ruco::Window.new(6,1, :line_scroll_offset => 0, :line_scroll_threshold => 0)
        window.position = Ruco::Position.new(6,0)
        result = window.crop(['1','2','3','4','5','6','7','8','9'])
        result.should == ['2','3','4','5','6','7']
      end

      it "goes out of frame if column is out of frame" do
        window = Ruco::Window.new(1,6, :column_scroll_offset => 0, :column_scroll_threshold => 0)
        window.position = Ruco::Position.new(0,6)
        result = window.crop(['1234567890'])
        result.should == ['234567']
      end
    end
  end

  describe :top do
    let(:window){ Ruco::Window.new(10,10, :line_scroll_threshold => 1, :line_scroll_offset => 3) }

    it "does not change when staying in frame" do
      window.top.should == 0
      window.position = Ruco::Position.new(8,0)
      window.top.should == 0
    end

    it "changes by offset when going down out of frame" do
      window.position = Ruco::Position.new(9,0)
      window.top.should == 3
    end

    it "stays at bottom when going down out of frame" do
      window.position = Ruco::Position.new(20,0)
      window.top.should == 20 - 10 + 3 + 1
    end

    it "stays at top when going up out of frame" do
      window.position = Ruco::Position.new(20,0)
      window.position = Ruco::Position.new(7,0)
      window.top.should == 7 - 3
    end

    it "changes to 0 when going up to 1" do
      window.position = Ruco::Position.new(20,0)
      window.position = Ruco::Position.new(1,0)
      window.top.should == 0
    end

    it "does not change when staying in changed frame" do
      window.position = Ruco::Position.new(9,0)
      window.top.should == 3
      window.position = Ruco::Position.new(11,0)
      window.top.should == 3
    end
  end

  describe :left do
    let(:window){ Ruco::Window.new(10,10, :column_scroll_threshold => 1, :column_scroll_offset => 3) }

    it "does not change when staying in frame" do
      window.left.should == 0
      window.position = Ruco::Position.new(0,8)
      window.left.should == 0
    end

    it "changes by offset when going vertically out of frame" do
      window.position = Ruco::Position.new(0,8)
      window.position = Ruco::Position.new(0,9)
      window.left.should == 3
    end

    it "stays right when going right out of frame" do
      window.position = Ruco::Position.new(0,20)
      window.left.should == 20 - 10 + 3 + 1
    end

    it "stays left when going left out of frame" do
      window.position = Ruco::Position.new(0,20)
      window.position = Ruco::Position.new(0,7)
      window.left.should == 7 - 3
    end

    it "changes to 0 when going left out of frame to 1" do
      window.position = Ruco::Position.new(0,20)
      window.position = Ruco::Position.new(0,1)
      window.left.should == 0
    end

    it "does not change when staying in changed frame" do
      window.position = Ruco::Position.new(0,8)
      window.position = Ruco::Position.new(0,9)
      window.left.should == 3
      window.position = Ruco::Position.new(0,11)
      window.left.should == 3
    end
  end

  describe :set_top do
    it "sets" do
      window.set_top 1, 20
      window.top.should == 1
    end

    it "does not allow negative" do
      window.set_top -1, 20
      window.top.should == 0
    end

    it "does not go above maximum top" do
      window.set_top 20, 20
      window.top.should == 20 - 10 + 3 - 1
    end
  end

  describe :left= do
    it "sets" do
      window.left = 1
      window.left.should == 1
    end

    it "does not allow negative" do
      window.left = -1
      window.left.should == 0
    end
  end
end
