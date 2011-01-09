require File.expand_path('spec/spec_helper')

describe String do
  describe :naive_split do
    it "splits repeated pattern" do
      "aaa".naive_split('a').should == ['','','','']
    end

    it "splits normal stuff" do
      "abacad".naive_split('a').should == ['','b','c','d']
    end

    it "splits empty into 1" do
      "".naive_split('a').should == ['']
    end
  end

  describe :nth_index do
    it "finds the first by default" do
      "a a a".nth_index('a',0).should == 0
    end

    it "finds the n-th index" do
      "a a a".nth_index('a',2).should == 4
    end

    it "is nil when not found" do
      "b b b".nth_index('a',0).should == nil
      "b b b".nth_index('a',1).should == nil
    end
  end
end