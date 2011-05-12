require File.expand_path('spec/spec_helper')

describe Ruco::History do
  let(:history){ Ruco::History.new(:state => {:x => 1}, :track => [:x], :entries => 3) }

  it "knows its state" do
    history.state.should == {:x => 1}
  end

  it "can add a state" do
    history.add :insert, :x => 2
    history.state.should == {:x => 2}
  end

  it "can undo a state" do
    history.add :insert, :x => 2
    history.undo
    history.state.should == {:x => 1}
  end

  it "can undo-redo-undo a state" do
    history.add :insert, :x => 2
    history.undo
    history.redo
    history.state.should == {:x => 2}
  end

  it "cannot redo a modified stack" do
    history.add :insert, :x => 2
    history.undo
    history.add :insert, :x => 3
    history.redo
    history.state.should == {:x => 3}
    history.redo
    history.state.should == {:x => 3}
  end

  it "cannot undo into nirvana" do
    history.add :insert, :x => 2
    history.undo
    history.undo
    history.state.should == {:x => 1}
  end

  it "cannot redo into nirvana" do
    history.add :insert, :x => 2
    history.redo
    history.state.should == {:x => 2}
  end

  it "cannot undo unimportant changes" do
    history.add(:insert, :x => 1, :y => 1)
    history.undo
    history.state.should == {:x => 1}
  end

  it "tracks unimportant fields when an important one changes" do
    history.add(:insert, :x => 2, :y => 1)
    history.add(:insert, :x => 3)
    history.undo
    history.state.should == {:x => 2, :y => 1}
    history.undo
    history.state.should == {:x => 1}
  end

  it "does not track more than x states" do
    history.add(:insert, :x => 2)
    history.add(:insert, :x => 3)
    history.add(:insert, :x => 4)
    history.add(:insert, :x => 5)
    history.undo
    history.undo
    history.undo
    history.undo
    history.state.should == {:x => 3}
  end

  describe 'with timeout' do
    let(:history){ Ruco::History.new(:state => {:x => 1}, :track => [:x], :entries => 3, :timeout => 0.1) }

    it "adds fast changes" do
      history.add(:insert, :x => 2)
      history.add(:insert, :x => 3)
      history.add(:insert, :x => 4)
      history.undo
      history.state.should == {:x => 1}
    end

    it "does not modify undone states" do
      history.undo
      history.state.should == {:x => 1}
      history.add(:insert, :x => 4)
      history.undo
      history.state.should == {:x => 1}
    end

    it "does not modify redone states" do
      history.add(:insert, :x => 2)
      history.undo
      sleep 0.2
      history.redo
      history.state.should == {:x => 2}
      history.add(:insert, :x => 3)
      history.undo
      history.state.should == {:x => 2}
    end

    it "does not add slow changes" do
      history.add(:insert, :x => 2)
      history.add(:insert, :x => 3)
      sleep 0.2
      history.add(:insert, :x => 4)
      history.undo
      history.state.should == {:x => 3}
    end
  end
end