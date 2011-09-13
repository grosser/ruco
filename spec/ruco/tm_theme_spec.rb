require File.expand_path('spec/spec_helper')

describe Ruco::TMTheme do
  let(:theme){ Ruco::TMTheme.new('spec/fixtures/test.tmTheme') }

  it "parses foreground/background" do
    theme.foreground.should == '#4D4D4C'
    theme.background.should == '#FFFFFF'
  end

  it "parses rules" do
    theme.styles["keyword.operator.class"].should == [:black, nil]
  end
end
