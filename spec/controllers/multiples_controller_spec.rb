# coding: utf-8
require 'spec_helper'
require 'net/http'

describe MultiplesController do
  it "should use MultiplesController" do
    controller.should be_an_instance_of(MultiplesController)
  end

  context "With MogileFS Backend", :mogilefs => true do
    before do
      Factory(:confirm)
      @confirm = Factory(:confirm)
      @multiple = Factory.build(:multiple, :confirm => @confirm)
      @multiple.set_image_file :banner1, "#{File.dirname(__FILE__)}/../sample.jpg"
      @multiple.save
    end

    it "should return status 404 when requested non-existent column" do
      get 'image_delete', :confirm_id => @confirm.id, :id => @multiple.id, :column => 'picture'
      response.status.should == 404
    end

    it "should be deleted" do
      @mg.list_keys('').shift.should == ['bcadded5ee18bfa7c99834f307332b02.jpg']
      get 'image_delete', :confirm_id => @confirm.id, :id => @multiple.id, :column => 'banner1'
      response.status.should == 302
      response.header['Location'].should == "http://test.host/confirms/2/multiples/#{@multiple.id}/edit"
      MogileImage.count.should == 0
      @mg.list_keys('').should be_nil
      @multiple.reload[:banner1].should be_nil
    end

    it "should show alert on failure" do
      @multiple.banner1 = nil
      @multiple.save!
      get 'image_delete', :confirm_id => @confirm.id, :id => @multiple.id, :column => 'banner1'
      response.status.should == 302
      response.header['Location'].should == "http://test.host/confirms/2/multiples/#{@multiple.id}/edit"
      flash.now[:alert].should == 'Failed to delete image.'
    end

    it "image-delete url should be correctly set with nested resource" do
      get 'edit', :confirm_id => @multiple.confirm_id, :id => @multiple.id
      controller.url_for(:action => 'image_delete', :column => 'banner2').should ==
        'http://test.host/confirms/2/multiples/1/image_delete?column=banner2'
    end
  end
end

