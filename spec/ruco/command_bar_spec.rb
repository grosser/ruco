require File.expand_path('spec/spec_helper')

describe Ruco::CommandBar do
  let(:default_view){ "^W Exit    ^S Save    ^F Find" }
  let(:bar){ Ruco::CommandBar.new(:columns => 30) }

  it "shows shortcuts by default" do
    bar.view.should == default_view
  end

  it "shows less shortcuts when space is low" do
    bar = Ruco::CommandBar.new(:columns => 29)
    bar.view.should == default_view
    bar = Ruco::CommandBar.new(:columns => 28)
    bar.view.should == "^W Exit    ^S Save"
  end

  describe :ask do
    it "sets command bar into question mode" do
      bar.ask('Find: '){}
      bar.view.should == "Find: "
      bar.cursor.column.should == 6
    end

    it "can enter answer" do
      bar.ask('Find: '){}
      bar.insert('abc')
      bar.view.should == "Find: abc"
      bar.cursor.column.should == 9
    end

    it "gets reset when submitting" do
      bar.ask('Find: '){}
      bar.insert("123\n")
      bar.view.should == default_view
    end

    it "keeps entered answer when cached" do
      bar.ask('Find: ', :cache => true){}
      bar.insert('abc')
      bar.insert("\n")
      bar.ask('Find: ', :cache => true){}
      bar.view.should == "Find: abc"
      bar.cursor.column.should == 9
    end

    it "reset the question when cached" do
      bar.ask('Find: ', :cache => true){}
      bar.insert('abc')
      bar.reset

      bar.view.should == default_view
      bar.ask('Find: ', :cache => true){}
      bar.view.should == "Find: " # term removed
    end

    it "does not reset all cached questions" do
      bar.ask('Find: ', :cache => true){}
      bar.insert("abc\n")

      bar.ask('Foo: ', :cache => true){}
      bar.reset # clears Foo not Find
      bar.view.should == default_view

      bar.ask('Find: ', :cache => true){}
      bar.view.should == "Find: abc"
    end

    it "gets reset when starting a new question" do
      bar.ask('Find: '){}
      bar.insert('123')
      bar.ask('Find: '){}
      bar.view.should == "Find: "
    end

    it "can execute" do
      bar.ask('Find: ', :cache => true){|r| @result = r }
      bar.insert('abc')
      bar.insert("d\n")
      @result.should == 'abcd'
    end
  end
end