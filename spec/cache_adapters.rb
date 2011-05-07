# coding: utf-8

require 'spec_helper'
Dir["#{File.dirname(__FILE__)}/../lib/acts_as_image_store/cache_adapters/*.rb"].each { |f| require f }

describe ActsAsImageStore::CacheAdapters do
  adapters = [:file_system]

  before do
    @caches = []
    adapters.each do |a|
      klass = ::ActsAsImageStore::CacheAdapters.const_get(a.to_s.camelcase)
      klass.load(self)
      @caches.push klass.new(ActsAsImageStore.backend[:storage][a])
    end
  end

  it "should accept single item" do
    @caches.each do |s|
      s.store('123', 'jpg', 'raw', 'abc')
      s.fetch('123', 'jpg', 'raw').should == 'abc'
      s.exist?('123', 'jpg', 'raw').should be_true
      s.exist?('456', 'jpg', 'raw').should be_false
      s.exist?('123', 'png', 'raw').should be_false
      s.remove('123')
      s.exist?('123', 'jpg', 'raw').should be_false
    end
  end

  it "should accept multiple items" do
    @caches.each do |s|
      s.store('123', 'jpg', 'raw', 'abc')
      s.store('123', 'jpg', '80x80', 'aabbcc')
      s.store('123', 'png', '60x60', 'abcdef')
      s.store('456', 'gif', '100x100', 'def')
      s.fetch('123', 'png', '60x60').should == 'abcdef'
      s.url('123', 'png', '60x60').should == ['/images/60x60/123.png']
      s.list('123').sort.should == [['jpg', '80x80'], ['jpg', 'raw'], ['png', '60x60']]
      s.list('456').sort.should == [['gif', '100x100']]
      s.purge
      s.list('123').should == []
      s.list('456').should == []
    end
  end
end

