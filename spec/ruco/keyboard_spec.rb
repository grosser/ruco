# encoding: UTF-8
require File.expand_path('spec/spec_helper')

describe Keyboard do
  before do
    Curses.stub!(:getch).and_return Keyboard::NOTHING
  end

  def get_keys(count=1)
    keys = []
    Keyboard.listen do |key|
      keys << key
      break if keys.size == count
    end
    keys
  end

  it "can listen to simple keys" do
    Curses.should_receive(:getch).and_return 32
    get_keys.should == [' ']
  end

  it "can listen to multiple keys" do
    Curses.should_receive(:getch).and_return 32
    Curses.should_receive(:getch).and_return 97
    get_keys(2).should == [' ','a']
  end

  it "can listen ctrl+x" do
    Curses.should_receive(:getch).and_return 26
    get_keys.should == [:'Ctrl+z']
  end

  it "can listen to enter" do
    Curses.should_receive(:getch).and_return 13
    get_keys.should == [:enter]
  end

  it "does not listen to nil / NOTHING" do
    Curses.should_receive(:getch).and_return Keyboard::NOTHING
    Curses.should_receive(:getch).and_return nil
    Curses.should_receive(:getch).and_return 13
    get_keys.should == [:enter]
  end

  it "can fetch sequences" do
    Curses.should_receive(:getch).and_return 195
    Curses.should_receive(:getch).and_return 164
    get_keys.should == ['ä']
  end
end