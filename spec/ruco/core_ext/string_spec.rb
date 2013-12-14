require "spec_helper"

describe String do
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
