require File.expand_path('spec/spec_helper')

describe Ruco::History do
  let(:history){ Ruco::History.new(:state => {:x => 1}, :track => [:x]) }

  it "knows its state" do
    history.state.should == {:x => 1}
  end

  it "can add a state" do
    history.add :x => 2
    history.state.should == {:x => 2}
  end

  it "can undo a state" do
    history.add :x => 2
    history.undo
    history.state.should == {:x => 1}
  end

  it "can undo-redo-undo a state" do
    history.add :x => 2
    history.undo
    history.redo
    history.state.should == {:x => 2}
  end

  it "cannot redo a modified stack" do
    history.add :x => 2
    history.undo
    history.add :x => 3
    history.redo
    history.state.should == {:x => 3}
    history.redo
    history.state.should == {:x => 3}
  end

  it "cannot undo into nirvana" do
    history.add :x => 2
    history.undo
    history.undo
    history.state.should == {:x => 1}
  end

  it "cannot redo into nirvana" do
    history.add :x => 2
    history.redo
    history.state.should == {:x => 2}
  end

  it "cannot undo unimportant changes" do
    history.add(:x => 1, :y => 1)
    history.undo
    history.state.should == {:x => 1}
  end

  it "tracks unimportant fields when an important one changes" do
    history.add(:x => 2, :y => 1)
    history.add(:x => 3)
    history.undo
    history.state.should == {:x => 2, :y => 1}
    history.undo
    history.state.should == {:x => 1}
  end
end