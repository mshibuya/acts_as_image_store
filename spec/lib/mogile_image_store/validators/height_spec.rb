# coding: utf-8
require 'spec_helper'

describe MogileImageStore do
  context "Validators" do
    context "Height" do
      describe "with <=500 validation" do
        before{ @image = ImageHeightMax500.new }
        it "should accept 445 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.png")
          })
          @image.valid?.should be_true
        end

        it "should not accept 544 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.jpg',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.jpg")
          })
          @image.valid?.should be_false
        end
      end

      describe "with >=500 validation" do
        before{ @image = ImageHeightMin500.new }
        it "should not accept 445 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.png")
          })
          @image.valid?.should be_false
        end

        it "should accept 544 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.jpg',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.jpg")
          })
          @image.valid?.should be_true
        end
      end

      describe "with 430-500 validation" do
        before{ @image = ImageHeightMin430Max500.new }
        it "should not accept 420 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.gif")
          })
          @image.valid?.should be_false
        end

        it "should accept 445 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.png")
          })
          @image.valid?.should be_true
        end

        it "should not accept 544 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.jpg',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.jpg")
          })
          @image.valid?.should be_false
        end
      end
    end
  end
end

