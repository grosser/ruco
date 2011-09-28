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

  it "can get unstored stuff" do
    store.get('xxx').should == nil
  end

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

  it "can cache" do
    store.cache('x'){ 1 }.should == 1
    store.cache('x'){ 2 }.should == 1
  end

  it "can cache false" do
    store.cache('x'){ false }.should == false
    store.cache('x'){ 2 }.should == false
  end

  it "does not cache nil" do
    store.cache('x'){ nil }.should == nil
    store.cache('x'){ 2 }.should == 2
  end

  it "can delete" do
    store.set('x', 1)
    store.set('y', 2)
    store.delete('x')
    store.get('x').should == nil
    store.get('y').should == 2
  end

  it "can delete uncached" do
    store.set('x', 1)
    store.delete('z')
    store.get('x').should == 1
    store.get('z').should == nil
  end

  it "can clear" do
    store.set('x', 1)
    store.clear
    store.get('x').should == nil
  end

  it "can clear unstored" do
    store.clear
    store.get('x').should == nil
  end

  it "can store pure strings" do
    store = Ruco::FileStore.new(@folder, :keep => 3, :string => true)
    store.set('xxx','yyy')
    File.read(store.file('xxx')).should == 'yyy'
    store.get('xxx').should == 'yyy'
  end

  it "works without colors" do
    store = Ruco::FileStore.new(@folder)
    store.set('xxx',1)
    store.get('xxx').should == 1
  end
end
