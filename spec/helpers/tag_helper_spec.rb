# coding: utf-8
require 'spec_helper'

describe ActionView::Helpers::TagHelper do
  it "should show image tag" do
    image('0123456789abcdef0123456789abcdef.jpg').should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/raw/0123456789abcdef0123456789abcdef.jpg" />'
  end

  it "should show image tag with size" do
    image('0123456789abcdef0123456789abcdef.jpg', :w => 80, :h => 80).should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/80x80/0123456789abcdef0123456789abcdef.jpg" />'
  end

  it "should show image tag with string-keyed size" do
    image('0123456789abcdef0123456789abcdef.jpg', 'w' => 80, 'h' => 80).should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/80x80/0123456789abcdef0123456789abcdef.jpg" />'
  end

  it "should show image tag with size and format" do
    image('0123456789abcdef0123456789abcdef.jpg', :w => 80, :h => 80, :format => :png).should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/80x80/0123456789abcdef0123456789abcdef.png" />'
  end

  it "should show image tag with size and alt" do
    image('0123456789abcdef0123456789abcdef.jpg', :w => 80, :h => 80, :alt => 'alt text').should == '<img alt="alt text" src="http://'+MogileImageStore.backend['imghost']+'/image/80x80/0123456789abcdef0123456789abcdef.jpg" />'
  end

  it "should show image tag with size and method" do
    image('0123456789abcdef0123456789abcdef.jpg', :w => 80, :h => 80, :method => :fill3).should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/80x80fill3/0123456789abcdef0123456789abcdef.jpg" />'
  end

  it "should show image tag with combined size" do
    image('0123456789abcdef0123456789abcdef.jpg', :size => '80x80fill5').should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/80x80fill5/0123456789abcdef0123456789abcdef.jpg" />'
  end

  it "should alternative image without key" do
    image('').should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/raw/44bd273c0eddca6de148fd717db8653e.jpg" />'
  end

  it "should specified alternative image without key" do
    image('', :default => :another).should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/raw/ffffffffffffffffffffffffffffffff.jpg" />'
  end

  context "thumbnail" do
    it "should show thumbnail with link to fullsize image" do
      thumbnail('0123456789abcdef0123456789abcdef.jpg').should == '<a href="http://'+MogileImageStore.backend['imghost']+'/image/raw/0123456789abcdef0123456789abcdef.jpg" target="_blank"><img src="http://'+MogileImageStore.backend['imghost']+'/image/80x80/0123456789abcdef0123456789abcdef.jpg" /></a>'
    end

    it "should show thumbnail without link" do
      thumbnail('0123456789abcdef0123456789abcdef.jpg', :link => false).should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/80x80/0123456789abcdef0123456789abcdef.jpg" />'
    end

    it "should show sized thumbnail with link to fullsize image" do
      thumbnail('0123456789abcdef0123456789abcdef.jpg', :w => 60, :h => 90).should == '<a href="http://'+MogileImageStore.backend['imghost']+'/image/raw/0123456789abcdef0123456789abcdef.jpg" target="_blank"><img src="http://'+MogileImageStore.backend['imghost']+'/image/60x90/0123456789abcdef0123456789abcdef.jpg" /></a>'
    end

    it "should not show link with empty key" do
      thumbnail(nil).should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/80x80/44bd273c0eddca6de148fd717db8653e.jpg" />'
      thumbnail('').should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/80x80/44bd273c0eddca6de148fd717db8653e.jpg" />'
    end
  end

  describe "when imghost is not set" do
    before(:all) do
      @imghost_backup = MogileImageStore.backend['imghost']
      MogileImageStore.backend.delete 'imghost'
    end
    after(:all) do
      MogileImageStore.backend['imghost'] = @imghost_backup
    end

    it "should show image tag with size and alt with hostname" do
      image('0123456789abcdef0123456789abcdef.jpg', :w => 80, :h => 80, :alt => 'alt text').should == '<img alt="alt text" src="/image/80x80/0123456789abcdef0123456789abcdef.jpg" />'
    end
  end
  describe "when imghost begins with scheme " do
    before(:all) do
      @imghost_backup = MogileImageStore.backend['imghost']
      MogileImageStore.backend['imghost'] = 'https://img.example.com'
    end
    after(:all) do
      MogileImageStore.backend['imghost'] = @imghost_backup
    end

    it "should show image tag with size and alt with hostname" do
      image('0123456789abcdef0123456789abcdef.jpg', :w => 80, :h => 80, :alt => 'alt text').should == '<img alt="alt text" src="https://img.example.com/image/80x80/0123456789abcdef0123456789abcdef.jpg" />'
    end
  end
end
