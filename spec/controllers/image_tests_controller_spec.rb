# coding: utf-8
require 'spec_helper'
require 'net/http'

describe ImageTestsController do
  it "should use ImageTestsController" do
    controller.should be_an_instance_of(ImageTestsController)
  end

  context "With MogileFS Backend", :mogilefs => true do
    before do
      @image_test = Factory.build(:image_test)
      @image_test.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.jpg"
      @image_test.save
    end

    it "should return status 404 when requested non-existent column" do
      get 'image_delete', :id => @image_test.id, :column => 'picture'
      response.status.should == 404
    end

    it "should be deleted" do
      @mg.list_keys('').shift.should == ['bcadded5ee18bfa7c99834f307332b02.jpg']
      get 'image_delete', :id => @image_test.id, :column => 'image'
      response.status.should == 302
      response.header['Location'].should == "http://test.host/image_tests/#{@image_test.id}/edit"
      MogileImage.count.should == 0
      @mg.list_keys('').should be_nil
      @image_test.reload[:image].should be_nil
    end

    it "should show alert on failure" do
      @image_test.image = nil
      @image_test.save!
      get 'image_delete', :id => @image_test.id, :column => 'image'
      response.status.should == 302
      response.header['Location'].should == "http://test.host/image_tests/#{@image_test.id}/edit"
      flash.now[:alert].should == 'Failed to delete image.'
    end
  end
end

