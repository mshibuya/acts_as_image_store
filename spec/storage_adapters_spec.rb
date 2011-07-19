# coding: utf-8

require 'spec_helper'
Dir["#{File.dirname(__FILE__)}/../lib/acts_as_image_store/storage_adapters/*.rb"].each { |f| require f }

adapters = [:file_system, :s3, :database]

adapters.each do |a|
  klass = ::ActsAsImageStore::StorageAdapters.const_get(a.to_s.camelcase)
  klass.load(self)
  storage = klass.new(ActsAsImageStore.backend[a])

  describe klass, :truncation => true do
    before do
      @s = storage
      @r = StoredImage.new :name => '123', :image_type => 'jpg'
      @t = StoredImage.new :name => '456', :image_type => 'jpg'
      @u = StoredImage.new :name => '156', :image_type => 'jpg'
    end
    after do
      @s.purge
    end

    it "should accept single item" do
      @s.store(@r, 'abc')
      @r.save # should be done because saving of record is done outside of adapter
      @s.fetch(@r).should == 'abc'
      @s.exist?('123.jpg').should be_true
      @s.exist?('456.jpg').should be_false
      @s.remove(@r)
      @r.save
      @s.exist?('123.jpg').should be_false
    end

    it "should accept multiple items" do
      @s.store(@r, 'abc')
      @r.save
      @s.store(@t, 'def')
      @t.save
      @s.store(@u, 'ghi')
      @u.save
      @s.list_keys.sort.should == ['123.jpg', '156.jpg', '456.jpg']
      @s.list_keys('1').sort.should == ['123.jpg', '156.jpg']
      @s.purge
      @s.list_keys.should == []
    end
  end
end

