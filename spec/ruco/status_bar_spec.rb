require File.expand_path('spec/spec_helper')

describe Ruco::StatusBar do
  let(:editor){ Ruco::Editor.new('spec/temp.txt', :lines => 5, :columns => 10) }
  let(:bar){ Ruco::StatusBar.new(editor, :columns => 10) }

  it "shows name and version" do
    bar.view.should include("Ruco #{Ruco::VERSION}") 
  end
end