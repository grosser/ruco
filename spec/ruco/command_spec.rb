require File.expand_path('spec/spec_helper')

describe Ruco::Command do
  it "can invoke a recorded command" do
    Ruco::Command.new(:slice, 0,1).send_to("ab1").should == 'a'
  end

  it "can invoke a recorded command without arguments" do
    Ruco::Command.new(:strip).send_to(" a ").should == 'a'
  end
end