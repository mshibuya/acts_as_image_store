# coding: utf-8
require 'spec_helper'
require 'net/http'

describe StoredImagesController do
  it "should use StoredImagesController" do
    controller.should be_an_instance_of(StoredImagesController)
  end

  context "With MogileFS Backend" do
    before(:all) do
      #prepare mogilefs
      @mogadm = MogileFS::Admin.new :hosts  => ActsAsImageStore.backend['hosts']
      unless @mogadm.get_domains[ActsAsImageStore.backend['domain']]
        @mogadm.create_domain ActsAsImageStore.backend['domain']
        @mogadm.create_class  ActsAsImageStore.backend['domain'], ActsAsImageStore.backend['class'], 2 rescue nil
      end
      @mg = MogileFS::MogileFS.new({ :domain => ActsAsImageStore.backend['domain'], :hosts  => ActsAsImageStore.backend['hosts'] })
      @image_test = Factory.build(:image_test)
      @image_test.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.jpg"
      @image_test.save
    end
    before do
      @mg = MogileFS::MogileFS.new({ :domain => ActsAsImageStore.backend['domain'], :hosts  => ActsAsImageStore.backend['hosts'] })
    end
    after(:all) do
      #cleanup
      StoredImage.destroy_all
      @mogadm = MogileFS::Admin.new :hosts  => ActsAsImageStore.backend['hosts']
      @mg = MogileFS::MogileFS.new({ :domain => ActsAsImageStore.backend['domain'], :hosts  => ActsAsImageStore.backend['hosts'] })
      @mg.each_key('') {|k| @mg.delete k }
      @mogadm.delete_domain ActsAsImageStore.backend['domain']
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

    it "should respond 206 if reproxying is disabled" do
      post 'flush'
      response.status.should == 206
    end

    context "Reproxing" do
      before(:all) do
        ActsAsImageStore.backend['reproxy'] = true
        ActsAsImageStore.backend['cache']   = 7.days
      end
      after (:all){ ActsAsImageStore.backend['reproxy'] = false }

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

      it "should respond 401 with authorization failure" do
        request.env[ActsAsImageStore::AUTH_HEADER_ENV] = 'abc'
        request.env['RAW_POST_DATA'] = '/image/raw/bcadded5ee18bfa7c99834f307332b02.jpg'
        post 'flush'
        response.status.should == 401
      end

      it "should respond reproxy cache clear header" do
        request.env[ActsAsImageStore::AUTH_HEADER_ENV] = ActsAsImageStore.auth_key('/image/raw/bcadded5ee18bfa7c99834f307332b02.jpg')
        request.env['RAW_POST_DATA'] = '/image/raw/bcadded5ee18bfa7c99834f307332b02.jpg'
        post 'flush'
        response.should be_success
        response.header['X-REPROXY-CACHE-CLEAR'].should == '/image/raw/bcadded5ee18bfa7c99834f307332b02.jpg'
      end
    end
  end
end

