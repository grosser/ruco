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
        [nil, nil, nil, [:red], [:red], [:red], []],
        nil
      ]
    end

    it "reproduces merged styles" do
      map.add(:red, 1, 3..5)
      map.add(:reverse, 1, 2..4)
      # reverse at 2 -- reverse and red at 3,4 -- red at 5
      map.flatten.should == [
        nil,
        [nil, nil, [:reverse], [:reverse, :red], [:reverse, :red], [:red], []],
        nil
      ]
    end
  end
end