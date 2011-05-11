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

    it "does not keep block when cached" do
      x = 0
      bar.ask('Find: ', :cache => true){ x = 1 }
      bar.insert("\n")
      bar.ask('Find: ', :cache => true){ x = 2 }
      bar.insert("\n")
      x.should == 2
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

    it "selects last value on cache-hit so I can type for new value" do
      bar.ask('Find: ', :cache => true){}
      bar.insert('abc')
      bar.insert("\n")
      bar.ask('Find: ', :cache => true){}
      bar.cursor.column.should == 9
      bar.text_in_selection.should == 'abc'
    end

    it "can re-find when reopening the find bar" do
      @results = []
      bar.ask('Find: ', :cache => true){|r| @results << r }
      bar.insert('abc')
      bar.insert("\n")
      bar.ask('Find: ', :cache => true){|r| @results << r }
      bar.insert("\n")
      @results.should == ["abc","abc"]
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

  describe :style_map do
    let(:bar){ Ruco::CommandBar.new(:columns => 10) }

    it "is reverse" do
      bar.style_map.flatten.should == [[:reverse, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, :normal]]
    end

    it "has normal style for selected input field" do
      bar.ask('Q'){}
      bar.insert('abc')
      bar.selecting{ move(:to, 0,0) }
      bar.view.should == 'Q abc'
      bar.style_map.flatten.should == [[:reverse, nil, :normal, nil, nil, nil, :reverse, nil, nil, nil, nil, :normal]]
    end
  end
end
