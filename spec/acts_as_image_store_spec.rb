require 'spec_helper'
require 'mogilefs'

describe ActsAsImageStore do
  it "should be valid" do
    ActsAsImageStore.should be_a(Module)
  end

  context "configuration" do
    before(:all) do
      @mogilefs_bak = ActsAsImageStore::Engine.config.mogile_fs
    end
    after(:all) do
      ActsAsImageStore::Engine.config.mogile_fs = @mogilefs_bak
      ActsAsImageStore.configure
    end
    it 'should append slash to mount_at only when not ended with slash' do
      ActsAsImageStore::Engine.config.mogile_fs['test']['mount_at'] = '/foo/'
      ActsAsImageStore.configure
      ActsAsImageStore.backend[:mount_at].should == '/foo/'
      ActsAsImageStore::Engine.config.mogile_fs['test']['mount_at'] = '/foo'
      ActsAsImageStore.configure
      ActsAsImageStore.backend[:mount_at].should == '/foo/'
    end
    it 'should append slash to base_url only when not ended with slash' do
      ActsAsImageStore::Engine.config.mogile_fs['test']['mount_at'] = '/foo/'
      ActsAsImageStore::Engine.config.mogile_fs['test']['base_url'] = '/bar/'
      ActsAsImageStore.configure
      ActsAsImageStore.backend[:base_url].should == '/bar/'
      ActsAsImageStore::Engine.config.mogile_fs['test']['base_url'] = '/bar'
      ActsAsImageStore.configure
      ActsAsImageStore.backend[:base_url].should == '/bar/'
    end
    it 'should set base_url to default value on empty' do
      ActsAsImageStore::Engine.config.mogile_fs['test']['base_url'] = nil
      ActsAsImageStore.configure
      ActsAsImageStore.backend[:base_url].should == '/image/'
    end
  end
end
