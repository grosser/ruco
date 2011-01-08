require File.expand_path('spec/spec_helper')

describe Ruco::StatusBar do
  let(:file){ 'spec/temp.txt' }
  let(:editor){ Ruco::Editor.new(file, :lines => 5, :columns => 10) }
  let(:bar){ Ruco::StatusBar.new(editor, :columns => 10) }

  it "shows name and version" do
    bar.view.should include("Ruco #{Ruco::VERSION}") 
  end

  it "shows the file" do
    bar.view.should include(file)
  end

  it "indicates modified" do
    bar.view.should_not include('*')
    editor.insert('x')
    bar.view.should include('*')
  end
end