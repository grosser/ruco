require "spec_helper"

describe Ruco do
  it "has a VERSION" do
    Ruco::OLD_VERSION.should =~ /^\d+\.\d+\.\d+(\.[a-z\d]+)?$/
  end
end
