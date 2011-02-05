require File.expand_path('spec/spec_helper')

describe Ruco::TextArea do
  describe :move do
    describe 'pages' do
      it "can move down a page" do
        text = Ruco::TextArea.new("1\n2\n3\n4\n5\n6\n7\n8\n9\n", :lines => 3, :columns => 3)
        text.move(:page_down)
        text.view.should == "3\n4\n5\n"
        text.cursor.should == [1,0]
      end

      it "keeps cursor position when moving down" do
        text = Ruco::TextArea.new("1\n2abc\n3\n4\n5ab\n6\n7\n8\n9\n", :lines => 3, :columns => 5)
        text.move(:to, 1,4)
        text.move(:page_down)
        text.view.should == "4\n5ab\n6\n"
        text.cursor.should == [1,3]
      end

      it "can move up a page" do
        text = Ruco::TextArea.new("0\n1\n2\n3\n4\n5\n6\n7\n8\n", :lines => 3, :columns => 3)
        text.move(:to, 4, 0)
        text.view.should == "3\n4\n5\n"
        text.cursor.should == [1,0]
        text.move(:page_up)
        text.view.should == "0\n1\n2\n"
        text.cursor.should == [1,0]
      end

      it "keeps column position when moving up" do
        text = Ruco::TextArea.new("0\n1\n2ab\n3\n4\n5abc\n6\n7\n8\n9\n10\n11\n", :lines => 3, :columns => 5)
        text.move(:to, 5, 3)
        text.view.should == "4\n5abc\n6\n"
        text.cursor.should == [1,3]
        text.move(:page_up)
        text.view.should == "1\n2ab\n3\n"
        text.cursor.should == [1,3]
      end

      it "moves pages symetric" do
        text = Ruco::TextArea.new("0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n", :lines => 3, :columns => 3)
        text.move(:to, 4, 1)
        text.view.should == "3\n4\n5\n"
        text.cursor.should == [1,1]

        text.move(:page_down)
        text.move(:page_down)
        text.move(:page_up)
        text.move(:page_up)

        text.cursor.should == [1,1]
        text.view.should == "3\n4\n5\n"
      end
    end
  end
end