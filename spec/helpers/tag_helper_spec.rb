# coding: utf-8
require 'spec_helper'

describe ActionView::Helpers::TagHelper do
  it "should show image tag" do
    image('01234567890abcdef0123456789abcdef.jpg').should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/raw/01234567890abcdef0123456789abcdef.jpg" />'
  end

  it "should show image tag with size" do
    image('01234567890abcdef0123456789abcdef.jpg', :w => 80, :h => 80).should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/80x80/01234567890abcdef0123456789abcdef.jpg" />'
  end

  it "should show image tag with string-keyed size" do
    image('01234567890abcdef0123456789abcdef.jpg', 'w' => 80, 'h' => 80).should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/80x80/01234567890abcdef0123456789abcdef.jpg" />'
  end

  it "should show image tag with size and format" do
    image('01234567890abcdef0123456789abcdef.jpg', :w => 80, :h => 80, :format => :png).should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/80x80/01234567890abcdef0123456789abcdef.png" />'
  end

  it "should show image tag with size and alt" do
    image('01234567890abcdef0123456789abcdef.jpg', :w => 80, :h => 80, :alt => 'alt text').should == '<img alt="alt text" src="http://'+MogileImageStore.backend['imghost']+'/image/80x80/01234567890abcdef0123456789abcdef.jpg" />'
  end

  it "should show image tag with size and method" do
    image('01234567890abcdef0123456789abcdef.jpg', :w => 80, :h => 80, :method => :fill3).should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/80x80fill3/01234567890abcdef0123456789abcdef.jpg" />'
  end

  it "should show image tag with combined size" do
    image('01234567890abcdef0123456789abcdef.jpg', :size => '80x80fill5').should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/80x80fill5/01234567890abcdef0123456789abcdef.jpg" />'
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
      image('01234567890abcdef0123456789abcdef.jpg', :w => 80, :h => 80, :alt => 'alt text').should == '<img alt="alt text" src="/image/80x80/01234567890abcdef0123456789abcdef.jpg" />'
    end
  end
end
