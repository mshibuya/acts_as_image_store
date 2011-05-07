# coding: utf-8

require 'spec_helper'
Dir["#{File.dirname(__FILE__)}/../lib/acts_as_image_store/cache_adapters/*.rb"].each { |f| require f }

adapters = [:file_system, :s3]
adapters.each do |a|
  klass = ::ActsAsImageStore::CacheAdapters.const_get(a.to_s.camelcase)
  klass.load(self)
  cache = klass.new(ActsAsImageStore.backend[a])
  describe klass do
    after{ cache.purge }

    it "should accept single item" do
      s = cache
      s.store('123', 'jpg', 'raw', 'abc')
      s.fetch('123', 'jpg', 'raw').should == 'abc'
      s.exist?('123', 'jpg', 'raw').should be_true
      s.exist?('456', 'jpg', 'raw').should be_false
      s.exist?('123', 'png', 'raw').should be_false
      s.remove('123')
      s.exist?('123', 'jpg', 'raw').should be_false
    end

    it "should accept multiple items" do
      s = cache
      s.store('123', 'jpg', 'raw', 'abc')
      s.store('123', 'jpg', '80x80', 'aabbcc')
      s.store('123', 'png', '60x60', 'abcdef')
      s.store('456', 'gif', '100x100', 'def')
      s.fetch('123', 'png', '60x60').should == 'abcdef'
      case a
      when :file_system
        s.url('123', 'png', '60x60').should == ['/images/60x60/123.png']
      when :s3
        s.url('123', 'png', '60x60').should == ['http://imagestore.test.s3.amazonaws.com/60x60/123.png']
      end
      s.list('123').sort.should == [['jpg', '80x80'], ['jpg', 'raw'], ['png', '60x60']]
      s.list('456').sort.should == [['gif', '100x100']]
      s.purge
      s.list('123').should == []
      s.list('456').should == []
    end
  end
end
