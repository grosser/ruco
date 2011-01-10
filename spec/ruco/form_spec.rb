require File.expand_path('spec/spec_helper')

describe Ruco::Form do
  let(:form){ Ruco::Form.new('Test', :columns => 30, :command => :find) }

  it "positions cursor in text field" do
    form.cursor.should == [0, 5]
  end

  describe :insert do
    it "adds label size and input size" do
      form.insert('abc')
      form.cursor.should == [0, 8]
    end

    it "returns nil on any insert" do
      form.insert('abc').should == nil
    end

    it "returns value on enter" do
      form.insert('abc')
      form.insert("d\n").should == Ruco::Command.new(:find, 'abcd')
    end
  end

  describe :move do
    it "moves in text-field" do
      form.insert('abc')
      form.move(0, -1)
      form.cursor.should == [0,7]
    end

    it "cannot move out of left side" do
      form.move(0, -3)
      form.cursor.should == [0,5]
    end

    it "cannot move out of right side" do
      form.move(0, 4)
      form.cursor.should == [0,5]
      form.insert('abc')
      form.move(0, 4)
      form.cursor.should == [0,8]
    end
  end

  describe :delete do
    it "removes characters forward" do
      form.insert('abc')
      form.move(0, -2)
      form.delete(1)
      form.view.should == 'Test ac' 
    end

    it "removes characters backward" do
      form.insert('abc')
      form.move(0, -1)
      form.delete(-1)
      form.view.should == 'Test ac'
    end

    it "moves the cursor backward" do
      form.insert('abc')
      form.move(0, -1)
      form.delete(-1)
      form.cursor.should == [0,6]
    end
  end

  describe :view do
    it "can be viewed" do
      form.view.should == "Test "
    end
  end
end