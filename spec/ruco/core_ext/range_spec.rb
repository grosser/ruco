require File.expand_path('spec/spec_helper')

describe Range do
  describe :last_element do
    it "is the last for normal ranges" do
      (1..2).last_element.should == 2
    end

    it "is the last for exclusive ranges" do
      (1...3).last_element.should == 2
    end
  end

  describe :move do
    it "does not modify the original" do
      a = 1..3
      a.move(3)
      a.should == (1..3)
    end

    it "can move 0" do
      (1..3).move(0).should == (1..3)
    end

    it "can move right" do
      (1..3).move(1).should == (2..4)
    end

    it "can move left" do
      (1..3).move(-2).should == (-1..1)
    end

    it "can move exclusive ranges" do
      (1...3).move(2).should == (3...5)
    end
  end
end
