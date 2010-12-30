# coding: utf-8
require 'spec_helper'

describe ActionView::Helpers::TagHelper do
  it "should show image tag" do
    image('01234567890abcdef0123456789abcdef.jpg').should == '<img src="/image/raw/01234567890abcdef0123456789abcdef.jpg" />'
  end

  it "should show image tag with size" do
    image('01234567890abcdef0123456789abcdef.jpg', :w => 80, :h => 80).should == '<img src="/image/80x80/01234567890abcdef0123456789abcdef.jpg" />'
  end

  it "should show image tag with size and alt" do
    image('01234567890abcdef0123456789abcdef.jpg', :w => 80, :h => 80, :alt => 'alt text').should == 
      '<img alt="alt text" src="/image/80x80/01234567890abcdef0123456789abcdef.jpg" />'
  end
end
