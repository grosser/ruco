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

    it "splits 1 into 2" do
      "a".naive_split('a').should == ['','']
    end
  end

  describe :surrounded_in? do
    [
      ['aba','a',true],
      ['abcab','ab',true],
      ['acc','a',false],
      ['cca','a',false],
      ['(cca)',['(',')'],true],
      ['(cca',['(',')'],false],
    ].each do |text, word, success|
      it "is #{success} for #{word} in #{text}" do
        text.surrounded_in?(*[*word]).should == success
      end
    end
  end
end
