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
        [nil, nil, nil, [:red], nil, nil, []],
        nil
      ]
    end

    it "reproduces merged styles" do
      map.add(:red, 1, 3..5)
      map.add(:reverse, 1, 2..4)
      # reverse at 2 -- reverse and red at 3,4 -- red at 5
      map.flatten.should == [
        nil,
        [nil, nil, [:reverse], [:reverse, :red], nil, [:red], []],
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
        [[:reverse], nil, []],
        [nil, nil, [:reverse], nil, []],
        nil
      ]
    end

    it "can shift" do
      s = Ruco::StyleMap.new(2)
      s.add(:reverse, 0, 0..1)
      s.add(:reverse, 1, 1..2)
      s.shift.flatten.should == [[[:reverse],nil,[]]]
      s.flatten.should == [[nil, [:reverse],nil,[]]]
    end

    it "can pop" do
      s = Ruco::StyleMap.new(2)
      s.add(:reverse, 0, 0..1)
      s.add(:reverse, 1, 1..2)
      s.pop.flatten.should == [[nil, [:reverse],nil,[]]]
      s.flatten.should == [[[:reverse],nil,[]]]
    end
  end
end