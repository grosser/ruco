require File.expand_path('spec/spec_helper')

describe Ruco::Window do
  describe :crop do
    let(:window){ Ruco::Window.new(2,4) }

    it "removes un-displayable chars" do
      result = window.crop(['12345','12345','12345'])
      result.should == ['1234','1234']
    end

    it "adds whitespace" do
      result = window.crop(['1','',''])
      result.should == ['1   ','    ']
    end

    it "creates lines if necessary" do
      result = window.crop(['1234'])
      result.should == ['1234','    ']
    end
  end
end