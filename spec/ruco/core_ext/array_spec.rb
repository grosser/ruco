require File.expand_path('spec/spec_helper')

describe Array do
  it "is bigger" do
    [1].should > [0]
    [1].should_not > [1]
  end

  it "is smaller" do
    [1].should < [2]
    [1].should_not < [1]
  end

  it "is smaller or equal" do
    [1].should <= [1]
    [1].should_not <= [0]
  end

  it "is bigger or equal" do
    [1].should >= [1]
    [1].should_not >= [2]
  end

  it "is between" do
    [1].between?([1],[1]).should == true
    [1].between?([1],[2]).should == true
    [1].between?([0],[1]).should == true
    [1].between?([0],[0]).should == false
    [1].between?([2],[2]).should == false
  end
end