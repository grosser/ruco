require "spec_helper"

describe Ruco::OptionAccessor do
  let(:options){ Ruco::OptionAccessor.new }

  it "can be accessed like a hash" do
    options[:xx].should == nil
    options[:xx] = 1
    options[:xx].should == 1
  end

  it "can be written" do
    options.foo = true
    options[:foo].should == true
  end

  it "can access nested keys" do
    options.foo_bar = 1
    options.history_size = 1
    options.nested(:history).should == {:size => 1}
  end

  it "has empty hash for nested key" do
    options.nested(:history).should == {}
  end
end
