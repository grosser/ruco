require File.expand_path('spec/spec_helper')

describe Ruco::SyntaxParser do
  def parse(text)
    sorted Ruco::SyntaxParser.parse_lines(text, :ruby)
  end

  def sorted(x)
    x.sort_by{|y| y.first.to_s }
  end

  describe :parse_lines do
    it "shows positions for simple lines" do
      parse(["class Foo","end"]).should == [
        [[:constant, 6...9], [:keyword, 0...5]],
        [[:keyword, 0...3]]
      ]
    end

    it "shows positions for complicated lines" do
      parse(["class foo end blob else Foo"]).should == [
        [[:constant, 24...27], [:keyword, 0...5], [:keyword, 10...13], [:keyword, 19...23]]
      ]
    end

    it "does not show keywords in strings" do
      parse(["Bar 'Bar' foo"]).should == [
        [[:string, 4...9], [:constant, 0...3]]
      ]
    end

    it "does not show strings in comments" do
      parse(["'Bar' # 'Bar'"]).should == [
        [[:comment, 6...13], [:string, 0...5]]
      ]
    end
  end
end
