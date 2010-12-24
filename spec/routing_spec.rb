# coding: utf-8
require 'spec_helper'

describe MogileImage do
  it{ { :get => '/image/raw/01234567890abcdef01234567890abcdef.jpg' }.should
    route_to(:controller => 'mogile_images', :size => 'raw', :name => '01234567890abcdef01234567890abcdef', :format => 'jpg') }
  it{ { :get => '/image/1x2/01234567890abcdef01234567890abcdef.gif' }.should
    route_to(:controller => 'mogile_images', :size => '1x2', :name => '01234567890abcdef01234567890abcdef', :format => 'gif') }
  it{ { :get => '/image/200x100/01234567890abcdef01234567890abcdef.png' }.should
    route_to(:controller => 'mogile_images', :size => '200x100', :name => '01234567890abcdef01234567890abcdef', :format => 'png') }
  it{ { :get => '/image/raw/01234567890abcdef01234567890abcdef' }.should_not be_routable }
  it{ { :get => '/image/raw/01234567890abcdef01234567890abcdef.pdf' }.should_not be_routable }
  it{ { :get => '/image/' }.should_not be_routable }
end
