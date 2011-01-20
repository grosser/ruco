# encoding: UTF-8
require File.expand_path('spec/spec_helper')

describe Keyboard do
  before do
    Curses.stub!(:getch).and_return Keyboard::NOTHING
  end

  def nil_input
    Curses.should_receive(:getch).and_return Keyboard::NOTHING
  end

  def get_keys(count=1, options={})
    keys = []
    Timeout.timeout(0.5) do
      Keyboard.listen do |key|
        keys << key
        sleep (options[:sleep]||[])[keys.size-1].to_i
        break if keys.size == count
      end
    end
    keys
  rescue Exception
    keys
  end

  it "can listen to simple keys" do
    Curses.should_receive(:getch).and_return 32
    get_keys(1).should == [' ']
  end

  it "can listen to multiple keys" do
    pending
    Curses.should_receive(:getch).and_return 32
    Curses.should_receive(:getch).and_return 97
    nil_input
    nil_input
    get_keys(2, :sleep => [0.1]).should == [' ','a']
  end

  it "can listen ctrl+x" do
    Curses.should_receive(:getch).and_return 26
    get_keys(1).should == [:'Ctrl+z']
  end

  it "can listen to enter" do
    Curses.should_receive(:getch).and_return 13
    get_keys(1).should == [:enter]
  end

  it "does not listen to nil / NOTHING" do
    Curses.should_receive(:getch).and_return Keyboard::NOTHING
    Curses.should_receive(:getch).and_return nil
    Curses.should_receive(:getch).and_return 13
    get_keys(1).should == [:enter]
  end

  it "can fetch sequences" do
    Curses.should_receive(:getch).and_return 195
    Curses.should_receive(:getch).and_return 164
    get_keys(1).should == ['ä']
  end

  it "cannot fetch long sequences" do
    pending
    Curses.should_receive(:getch).and_return 195
    Curses.should_receive(:getch).and_return 164
    get_keys(2,:sleep => [0.1]).size.should == 2
  end

  it "fetches pastes between normal key strokes" do
    pending
    Curses.should_receive(:getch).exactly(5).and_return 32
    get_keys(5,:sleep => [0.1,0.002,0.002,0.002,0.1]).should == [' ','   ',' ']
  end
end