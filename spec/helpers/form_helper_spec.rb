# coding: utf-8
require 'spec_helper'

describe ActionView::Helpers::FormHelper do
  before do
    @image_test = Factory.build(:image_test)
    @image_test.image = '01234567890abcdef0123456789abcdef.jpg'
    @image_test.save
  end

  it "should respond_to image_field" do
    form_for(@image_test) do |f|
      f.image_field(:image).should == '<img src="/image/80x80/01234567890abcdef0123456789abcdef.jpg" /><a href="/image_tests/'+@image_test.id.to_s+'/image_delete/image">delete</a><br /><input id="image_test_image" name="image_test[image]" type="file" />'
    end
  end
end
