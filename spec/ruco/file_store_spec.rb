require File.expand_path('spec/spec_helper')

describe Ruco::FileStore do
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
    sleep 1
    store.set('yyy', 2)
    sleep 1
    store.set('zzz', 3)
    sleep 1
    store.set('aaa', 4)
    store.get('xxx').should == nil
  end

  it "drops least recently used key" do
    store.set('xxx', 1)
    sleep(1)
    store.set('yyy', 1)
    sleep(1)
    store.set('xxx', 1)
    sleep(1)
    store.set('zzz', 1)
    sleep(1)
    store.set('aaa', 1)
    sleep(1)
    store.get('xxx').should == 1
    store.get('yyy').should == nil
  end

  it "does not drop if used multiple times" do
    store.set('xxx', 1)
    sleep(1)
    store.set('yyy', 1)
    sleep(1)
    store.set('zzz', 1)
    sleep(1)
    store.set('zzz', 1)
    sleep(1)
    store.set('zzz', 1)
    sleep(1)
    store.set('zzz', 1)
    sleep(1)
    store.get('xxx').should == 1
  end
end
