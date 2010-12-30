# coding: utf-8
require 'spec_helper'
require 'net/http'

describe ImageTestsController do
  it "should use ImageTestsController" do
    controller.should be_an_instance_of(ImageTestsController)
  end

  context "With MogileFS Backend" do
    before(:all) do
      #prepare mogilefs
      @mogadm = MogileFS::Admin.new :hosts  => MogileImageStore.backend['hosts']
      unless @mogadm.get_domains[MogileImageStore.backend['domain']]
        @mogadm.create_domain MogileImageStore.backend['domain']
        @mogadm.create_class  MogileImageStore.backend['domain'], MogileImageStore.backend['class'], 2 rescue nil
      end
      @mg = MogileFS::MogileFS.new({ :domain => MogileImageStore.backend['domain'], :hosts  => MogileImageStore.backend['hosts'] })
      @image_test = Factory.build(:image_test)
      @image_test.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.jpg"
      @image_test.save
    end
    before do
      @mg = MogileFS::MogileFS.new({ :domain => MogileImageStore.backend['domain'], :hosts  => MogileImageStore.backend['hosts'] })
    end
    after(:all) do
      #cleanup
      ImageTest.delete_all
      MogileImage.delete_all
      @mogadm = MogileFS::Admin.new :hosts  => MogileImageStore.backend['hosts']
      @mg = MogileFS::MogileFS.new({ :domain => MogileImageStore.backend['domain'], :hosts  => MogileImageStore.backend['hosts'] })
      @mg.each_key('') {|k| @mg.delete k }
      @mogadm.delete_domain MogileImageStore.backend['domain']
    end

    it "should return status 404 when requested non-existent column" do
      get 'image_delete', :id => @image_test.id, :column => 'picture'
      response.status.should == 404
    end

    it "should be deleted" do
      @mg.list_keys('').shift.should == ['bcadded5ee18bfa7c99834f307332b02.jpg']
      get 'image_delete', :id => @image_test.id, :column => 'image'
      response.status.should == 302
      response.header['Location'].should == "http://test.host/image_tests/#{@image_test.id}"
      MogileImage.count.should == 0
      @mg.list_keys('').should be_nil
    end
  end
end

