require File.expand_path('spec/spec_helper')

describe Ruco do
  it "has a VERSION" do
    Ruco::VERSION.should =~ /^\d+\.\d+\.\d+$/
  end
end