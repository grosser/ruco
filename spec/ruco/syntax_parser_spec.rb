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
      parse(["class Foo","end"]).should == [[
        ["keyword.control.class.ruby", 0...5],
        ["entity.name.type.class.ruby", 6...9],
        ["meta.class.ruby", 0...9]],
        [["keyword.control.ruby", 0...3]
      ]]
    end

    it "shows positions for complicated lines" do
      parse(["class foo end blob else Foo"]).should == [[
        ["keyword.control.class.ruby", 0...5],
        ["entity.name.type.class.ruby", 6...9],
        ["meta.class.ruby", 0...9],
        ["keyword.control.ruby", 10...13],
        ["keyword.control.ruby", 19...23],
        ["variable.other.constant.ruby", 24...27]
      ]]
    end

    it "does not show keywords in strings" do
      parse(["Bar 'Bar' foo"]).should == [[
        ["variable.other.constant.ruby", 0...3],
        ["punctuation.definition.string.begin.ruby", 4...5],
        ["punctuation.definition.string.end.ruby", 8...9],
        ["string.quoted.single.ruby", 4...9]
      ]]
    end

    it "does not show strings in comments" do
      parse(["'Bar' # 'Bar'"]).should == [[
        ["punctuation.definition.string.begin.ruby", 0...1],
        ["punctuation.definition.string.end.ruby", 4...5],
        ["string.quoted.single.ruby", 0...5],
        ["punctuation.definition.comment.ruby", 6...7],
        ["comment.line.number-sign.ruby", 6...13]
      ]]
    end
  end
end
