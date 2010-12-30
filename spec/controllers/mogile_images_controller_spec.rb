# coding: utf-8
require 'spec_helper'
require 'net/http'

describe MogileImagesController do
  it "should use MogileImagesController" do
    controller.should be_an_instance_of(MogileImagesController)
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
      MogileImage.destroy_all
      @mogadm = MogileFS::Admin.new :hosts  => MogileImageStore.backend['hosts']
      @mg = MogileFS::MogileFS.new({ :domain => MogileImageStore.backend['domain'], :hosts  => MogileImageStore.backend['hosts'] })
      @mg.each_key('') {|k| @mg.delete k }
      @mogadm.delete_domain MogileImageStore.backend['domain']
    end

    it "should return raw jpeg image" do
      get 'show', :name => 'bcadded5ee18bfa7c99834f307332b02', :format => 'jpg', :size => 'raw'
      response.should be_success
      response.header['Content-Type'].should == 'image/jpeg'
      img = ::Magick::Image.from_blob(response.body).shift
      img.format.should == 'JPEG'
      img.columns.should == 725
      img.rows.should == 544
    end

    it "should return status 404 when requested non-existent image" do
      get 'show', :name => 'bcadded5ee18bfa7c99834f307332b01', :format => 'jpg', :size => 'raw'
      response.status.should == 404
    end

    context "Reproxing" do
      before(:all) do
        MogileImageStore.backend['reproxy'] = true
        MogileImageStore.backend['cache']   = 7.days
      end
      after (:all){ MogileImageStore.backend['reproxy'] = false }

      it "should return url for jpeg image" do
        get 'show', :name => 'bcadded5ee18bfa7c99834f307332b02', :format => 'jpg', :size => 'raw'
        response.should be_success
        response.header['Content-Type'].should == 'image/jpeg'
        response.header['X-REPROXY-CACHE-FOR'].should == '604800; Content-Type'
        urls = response.header['X-REPROXY-URL'].split(' ')
        url = URI.parse(urls.shift)
        img = ::Magick::Image.from_blob(Net::HTTP.get(url.host, url.path, url.port)).shift
        img.format.should == 'JPEG'
        img.columns.should == 725
        img.rows.should == 544
      end
    end
  end
end

