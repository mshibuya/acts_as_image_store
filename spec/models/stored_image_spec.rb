# coding: utf-8
require 'spec_helper'

describe StoredImage do
  it "should return image url" do
    StoredImage.image_url('60de57a8f5cd0a10b296b1f553cb41a9.png').should ==
      'http://image.example.com/images/raw/60de57a8f5cd0a10b296b1f553cb41a9.png'
  end

  describe "with instance" do
    before do
      @image_test = Factory.build(:image_test)
      @image_test.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.jpg"
      @image_test.save!
      StoredImage.send(:class_variable_set, :@@storage, nil)
      StoredImage.send(:class_variable_set, :@@cache, nil)
    end

    it "should not raise error about missing @@storage/@@cache" do
      r = StoredImage.all.first
      lambda{ r.purge_image_data }.should_not raise_error
    end

    it "should have non-ASCII-8BIT encoded name" do
      StoredImage.first.name.encoding.should_not == Encoding::ASCII_8BIT
    end
  end
end

