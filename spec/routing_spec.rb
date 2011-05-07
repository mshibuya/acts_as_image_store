# coding: utf-8
require 'spec_helper'

describe StoredImage do
  it{ { :get => '/images/raw/0123456789abcdef0123456789abcdef.jpg' }.should route_to(:controller => 'stored_images', :action => 'show', :size => 'raw', :name => '0123456789abcdef0123456789abcdef', :format => 'jpg') }
  it{ { :get => '/images/1x2/0123456789abcdef0123456789abcdef.gif' }.should route_to(:controller => 'stored_images', :action => 'show', :size => '1x2', :name => '0123456789abcdef0123456789abcdef', :format => 'gif') }
  it{ { :get => '/images/200x100/0123456789abcdef0123456789abcdef.png' }.should route_to(:controller => 'stored_images', :action => 'show', :size => '200x100', :name => '0123456789abcdef0123456789abcdef', :format => 'png') }
  it{ { :get => '/images/200x100fill/0123456789abcdef0123456789abcdef.png' }.should route_to(:controller => 'stored_images', :action => 'show', :size => '200x100fill', :name => '0123456789abcdef0123456789abcdef', :format => 'png') }
  it{ { :get => '/images/200x100fill3/0123456789abcdef0123456789abcdef.png' }.should route_to(:controller => 'stored_images', :action => 'show', :size => '200x100fill3', :name => '0123456789abcdef0123456789abcdef', :format => 'png') }
  it{ { :post => '/images/flush' }.should route_to(:controller => 'stored_images', :action => 'flush') }
  it{ { :get => '/images/raw/0123456789abcdef0123456789abcdef' }.should_not be_routable }
  it{ { :get => '/images/raw/0123456789abcdef0123456789abcdef' }.should_not be_routable }
  it{ { :get => '/images/raw/0123456789abcdef0123456789abcdef.pdf' }.should_not be_routable }
  it{ { :post => '/images/raw/0123456789abcdef0123456789abcdef.jpg' }.should_not be_routable }
  it{ { :put => '/images/raw/0123456789abcdef0123456789abcdef.jpg' }.should_not be_routable }
  it{ { :delete => '/images/raw/0123456789abcdef0123456789abcdef.jpg' }.should_not be_routable }
  it{ { :get => '/images/flush' }.should_not be_routable }
  it{ { :put => '/images/flush' }.should_not be_routable }
  it{ { :delete => '/images/flush' }.should_not be_routable }
  it{ { :get => '/images/' }.should_not be_routable }

  it{ { :get => '/image_tests/2/image_delete/image' }.should route_to(:controller => 'image_tests', :action => 'image_delete', :id => '2', :column => 'image') }
  it{ { :get => '/multiples/65/image_delete/banner' }.should route_to(:controller => 'multiples', :action => 'image_delete', :id => '65', :column => 'banner') }
end
