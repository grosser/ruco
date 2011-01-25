# encoding: UTF-8
require File.expand_path('spec/spec_helper')

describe Keyboard do
  def output
    keys = []
    Timeout.timeout(0.3) do
      Keyboard.output do |key|
        keys << key
      end
    end
    keys
  rescue Timeout::Error
    keys
  end

  def type(chars)
    Keyboard.input do
      char = chars.shift
      if char == :sleep_long
        sleep 0.1
        nil
      else
        char
      end
    end
  end

  it "can listen to simple keys" do
    type [32]
    output.should == [' ']
  end

  it "can listen to multiple keys" do
    type [32, :sleep_long, 97]
    output.should == [' ','a']
  end

  it "can listen ctrl+x" do
    type [26]
    output.should == [:'Ctrl+z']
  end

  it "can listen to enter" do
    type [13]
    output.should == [:enter]
  end

  it "does not listen to nil / NOTHING" do
    type [nil, Keyboard::NOTHING, 13]
    output.should == [:enter]
  end

  it "can fetch uft8-chars" do
    type [195, 164]
    output.should == ['ä']
  end

  it "cannot fetch long sequences" do
    type [195, :sleep_long, 164]
    output.map{|s|s.bytes.to_a}.should == [[195], [164]]
  end

  it "fetches pastes between normal key strokes" do
    type [32, :sleep_long, 32, 13, 32, :sleep_long, 32]
    output.should == [' '," \n ",' ']
  end

  it "returns pastes that do not need indentation fix as normal chars" do
    type [32, :sleep_long, 32, 32, 32, :sleep_long, 32]
    output.should == [' ',' ',' ',' ',' ']
  end

  it "returns control chars separately" do
    type [260, 127, 127, 261, 260, 195, 164, 261, 260, 195, 164]
    output.should == [:left, :backspace, :backspace, :right, :left, "ä", :right, :left, "ä"]
  end

  it "ignores wtf number that is entered when using via ssh" do
    type [2**64-1, 2**32-1]
    output.should == []
  end

  it "returns key-code for unprintable keys" do
    type [11121, 324234]
    output.should == [11121, 324234]
  end

  it "recognises weird key combos" do
    type [27, 91, 49, 59, 50, 65]
    output.should == [:"Shift+up"]
    type [27, 91, 49, 59, 50, 66]
    output.should == [:"Shift+down"]
  end
end