require File.expand_path('spec/spec_helper')

describe Ruco::FileStore do
  def mark_all_as_old
    store.send(:entries).each{|e| File.utime(1,1,e) }
  end

  before do
    @folder = 'spec/sessions'
    `rm -rf #{@folder}`
  end

  after do
    `rm -rf #{@folder}`
  end

  let(:store){ Ruco::FileStore.new(@folder, :keep => 3) }

  it "can store stuff" do
    store.set('xxx', 1)
    store.get('xxx').should == 1
  end

  it "can store :keep keys" do
    store.set('xxx', 1)
    store.set('yyy', 1)
    store.set('zzz', 1)
    mark_all_as_old
    store.set('aaa', 2)
    store.get('aaa').should == 2
    ['xxx','yyy','zzz'].map{|f| store.get(f) }.should =~ [1,1,nil]
  end

  it "does not drop if used multiple times" do
    store.set('xxx', 1)
    store.set('yyy', 1)
    store.set('zzz', 1)
    store.set('zzz', 1)
    mark_all_as_old
    store.set('zzz', 1)
    store.set('zzz', 1)
    store.get('xxx').should == 1
  end
end
