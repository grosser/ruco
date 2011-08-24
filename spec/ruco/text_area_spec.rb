require File.expand_path('spec/spec_helper')

describe Ruco::TextArea do
  describe :move do
    describe 'pages' do
      it "can move down a page" do
        text = Ruco::TextArea.new("1\n2\n3\n4\n5\n6\n7\n8\n9\n", :lines => 3, :columns => 3)
        text.move(:page_down)
        text.view.should == "3\n4\n5"
        text.cursor.should == [1,0]
      end

      it "keeps cursor position when moving down" do
        text = Ruco::TextArea.new("1\n2abc\n3\n4\n5ab\n6\n7\n8\n9\n", :lines => 3, :columns => 5)
        text.move(:to, 1,4)
        text.move(:page_down)
        text.view.should == "4\n5ab\n6"
        text.cursor.should == [1,3]
      end

      it "can move up a page" do
        text = Ruco::TextArea.new("0\n1\n2\n3\n4\n5\n6\n7\n8\n", :lines => 3, :columns => 3)
        text.move(:to, 4, 0)
        text.view.should == "3\n4\n5"
        text.cursor.should == [1,0]
        text.move(:page_up)
        text.view.should == "0\n1\n2"
        text.cursor.should == [1,0]
      end

      it "keeps column position when moving up" do
        text = Ruco::TextArea.new("0\n1\n2ab\n3\n4\n5abc\n6\n7\n8\n9\n10\n11\n", :lines => 3, :columns => 5)
        text.move(:to, 5, 3)
        text.view.should == "4\n5abc\n6"
        text.cursor.should == [1,3]
        text.move(:page_up)
        text.view.should == "1\n2ab\n3"
        text.cursor.should == [1,3]
      end

      it "moves pages symetric" do
        text = Ruco::TextArea.new("0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n", :lines => 3, :columns => 3)
        text.move(:to, 4, 1)
        text.view.should == "3\n4\n5"
        text.cursor.should == [1,1]

        text.move(:page_down)
        text.move(:page_down)
        text.move(:page_up)
        text.move(:page_up)

        text.cursor.should == [1,1]
        text.view.should == "3\n4\n5"
      end
    end
  end

  describe :insert do
    let(:text){Ruco::TextArea.new("", :lines => 3, :columns => 10)}

    describe "inserting surrounding characters" do
      xit "does nothing special when pasting" do
        text.insert("'bar'")
        text.view.should == "'bar'\n\n"
        text.cursor.should == [0,5]
      end

      xit "inserts a pair when just typing" do
        text.insert("'")
        text.view.should == "''\n\n"
        text.cursor.should == [0,1]
      end

      xit "closes the surround if only char in surround" do
        text.insert("'")
        text.insert("'")
        text.view.should == "''\n\n"
        text.cursor.should == [0,2]
      end

      xit "overwrites next if its the same" do
        text.insert("'bar'")
        text.move(:relative, 0,-1)
        text.insert("'")
        text.view.should == "'bar'\n\n"
        text.cursor.should == [0,5]
      end

      it "surrounds text when selecting" do
        text.insert('bar')
        text.move(:to, 0,0)
        text.selecting{ move(:to, 0,2) }
        text.insert("{")
        text.view.should == "{ba}r\n\n"
        text.cursor.should == [0,4]
      end

      it "does not surround text with closing char when selecting" do
        text.insert('bar')
        text.move(:to, 0,0)
        text.selecting{ move(:to, 0,2) }
        text.insert("}")
        text.view.should == "}r\n\n"
        text.cursor.should == [0,1]
      end
    end
  end
end
