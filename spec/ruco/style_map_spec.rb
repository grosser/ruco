require File.expand_path('spec/spec_helper')

describe Ruco::StyleMap do
  let(:map){ Ruco::StyleMap.new(3) }

  describe :flat do
    it "is empty by default" do
      map.flatten.should == [nil, nil, nil]
    end

    it "reproduces simple styles" do
      map.add(:red, 1, 3..5)
      # red from 3 to 5
      map.flatten.should == [
        nil,
        [nil, nil, nil, :red, nil, nil, :normal],
        nil
      ]
    end

    it "reproduces merged styles" do
      map.add(:reverse, 1, 2..4)
      map.add(:red, 1, 3..5)
      # reverse at 2 -- reverse and red at 3,4 -- red at 5
      map.flatten.should == [
        nil,
        [nil, nil, :reverse, :red, nil, :red, :normal],
        nil
      ]
    end

    it "overwrites styles" do
      map.add(:reverse, 0, 0..1)
      map.add(:normal, 0, 0..1)
      map.flatten.should == [
        [:normal, nil, :normal],
        nil,
        nil
      ]
    end
  end

  describe 'array style operations' do
    it "adds two maps" do
      s1 = Ruco::StyleMap.new(1)
      s1.add(:reverse, 0, 0..1)
      s2 = Ruco::StyleMap.new(2)
      s2.add(:reverse, 0, 2..3)
      (s1 + s2).flatten.should == [
        [:reverse, nil, :normal],
        [nil, nil, :reverse, nil, :normal],
        nil
      ]
    end

    it "can shift" do
      s = Ruco::StyleMap.new(2)
      s.add(:reverse, 0, 0..1)
      s.add(:reverse, 1, 1..2)
      s.shift.flatten.should == [[:reverse, nil, :normal]]
      s.flatten.should == [[nil, :reverse, nil, :normal]]
    end

    it "can pop" do
      s = Ruco::StyleMap.new(2)
      s.add(:reverse, 0, 0..1)
      s.add(:reverse, 1, 1..2)
      s.pop.flatten.should == [[nil, :reverse, nil, :normal]]
      s.flatten.should == [[:reverse, nil, :normal]]
    end
  end

  describe :left_pad! do
    it "adds whitespace to left side" do
      s = Ruco::StyleMap.new(2)
      s.add(:reverse, 0, 0..1)
      s.add(:reverse, 1, 1..2)
      s.left_pad!(3)
      s.flatten.should == [
        [nil, nil, nil, :reverse, nil, :normal],
        [nil, nil, nil, nil, :reverse, nil, :normal]
      ]
    end
  end

  describe :invert! do
    it "inverts styles" do
      s = Ruco::StyleMap.new(2)
      s.add(:reverse, 0, 0..1)
      s.add(:normal, 1, 1..2)
      s.add(:red, 1, 4..5)
      s.invert!
      s.flatten.should == [
        [:normal, nil, :normal],
        [nil, :reverse, nil, nil, :red, nil, :normal]
      ]
    end
  end

  describe :styled do
    it "can style an unstyled line" do
      Ruco::StyleMap.styled("a", nil).should == [[:normal, "a"]]
    end

    it "can style a styled line" do
      Ruco::StyleMap.styled("a", [:reverse ,nil]).should == [[:normal, ""], [:reverse, "a"]]
    end

    it "keeps unstyled parts" do
      Ruco::StyleMap.styled("abc", [:reverse, :normal]).should == [[:normal, ""], [:reverse, "a"],[:normal,'bc']]
    end
  end
end
