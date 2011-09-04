require File.expand_path('spec/spec_helper')

describe Ruco::SyntaxParser do
  def parse(text)
    Ruco::SyntaxParser.parse_lines(text, :ruby)
  end

  describe :parse_lines do
    it "shows positions for simple lines" do
      parse(["class Foo","end"]).should == [
        [[:keyword, 0...5], [:constant, 6...9]],
        [[:keyword, 0...3]]
      ]
    end

    it "shows positions for complicated lines" do
      parse(["class foo end blob else Foo"]).should == [
        [[:keyword, 0...5], [:keyword, 10...13], [:keyword, 19...23], [:constant, 24...27]]
      ]
    end
  end
end
