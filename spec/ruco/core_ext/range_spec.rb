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
end
