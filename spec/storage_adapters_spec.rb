# coding: utf-8

require 'spec_helper'
Dir["#{File.dirname(__FILE__)}/../lib/acts_as_image_store/storage_adapters/*.rb"].each { |f| require f }

adapters = [:file_system, :s3]

adapters.each do |a|
  klass = ::ActsAsImageStore::StorageAdapters.const_get(a.to_s.camelcase)
  klass.load(self)
  storage = klass.new(ActsAsImageStore.backend[a])

  describe klass do
    after{ storage.purge }

    it "should accept single item" do
      s = storage
      s.store('123', 'abc')
      s.fetch('123').should == 'abc'
      s.exist?('123').should be_true
      s.exist?('456').should be_false
      s.remove('123')
      s.exist?('123').should be_false
    end

    it "should accept multiple items" do
      s = storage
      s.store('123', 'abc')
      s.store('456', 'def')
      s.store('156', 'ghi')
      s.list_keys.sort.should == ['123', '156', '456']
      s.list_keys('1').sort.should == ['123', '156']
      s.purge
      s.list_keys.should == []
    end
  end
end

