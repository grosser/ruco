require File.expand_path('spec/spec_helper')

describe Ruco::Window do

  describe :crop do
    let(:window){ Ruco::Window.new(2,4) }

    it "does not modify given lines" do
      original = ['1234','1234']
      window.crop(original)
      original.should == ['1234','1234']
    end

    it "removes un-displayable chars" do
      result = window.crop(['12345','12345','12345'])
      result.should == ['1234','1234']
    end

    it "adds whitespace" do
      result = window.crop(['1','',''])
      result.should == ['1   ','    ']
    end

    it "creates lines if necessary" do
      result = window.crop(['1234'])
      result.should == ['1234','    ']
    end

    it "stays inside frame as long as position is in frame" do
      window.position = Ruco::Position.new(1,3)
      result = window.crop(['12345678','12345678'])
      result.should == ['1234','1234']
    end

#    it "goes out of frame if position is out of frame" do
#      window.position = Ruco::Position.new(1,4)
#      result = window.crop(['1234567890','1234567890'])
#      result.should == ['5678','5678']
#    end
#
#    it "goes far out of frame" do
#      window.position = Ruco::Position.new(1,8)
#      result = window.crop(['1234567890','1234567890'])
#      result.should == ['5678','5678']
#    end
  end

  describe :top do
    let(:window){ Ruco::Window.new(10,10) }

    it "does not change when staying in frame" do
      window.top.should == 0
      window.position = Ruco::Position.new(9,0)
      window.top.should == 0
    end

    it "changes by offset when going vertically out of frame" do
      window.position = Ruco::Position.new(10,0)
      window.top.should == 5
    end

    it "changes to x - offset when going down out of frame" do
      window.position = Ruco::Position.new(20,0)
      window.top.should == 15
    end

    it "changes to x - offset when going down out of frame" do
      window.position = Ruco::Position.new(20,0)
      window.position = Ruco::Position.new(7,0)
      window.top.should == 2
    end
  end

  describe :left do
    let(:window){ Ruco::Window.new(10,10) }

    it "does not change when staying in frame" do
      window.left.should == 0
      window.position = Ruco::Position.new(0,9)
      window.left.should == 0
    end

    it "changes by offset when going vertically out of frame" do
      window.position = Ruco::Position.new(0,9)
      window.position = Ruco::Position.new(0,10)
      window.left.should == 5
    end

    it "changes to x - offset when going right out of frame" do
      window.position = Ruco::Position.new(0,20)
      window.left.should == 15
    end

    it "changes to x - offset when going left out of frame" do
      window.position = Ruco::Position.new(0,20)
      window.position = Ruco::Position.new(0,7)
      window.left.should == 2
    end

    it "does not change when staying in changed frame" do
      window.position = Ruco::Position.new(0,9)
      window.position = Ruco::Position.new(0,10)
      window.left.should == 5
      window.position = Ruco::Position.new(0,14)
      window.left.should == 5
    end
  end
end
