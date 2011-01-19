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
end