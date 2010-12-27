# coding: utf-8
require 'spec_helper'

describe MogileImageStore do
  context "Validators" do
    context "Width" do
      describe "with <=500 validation" do
        before{ @image = ImageWidthMax500.new }
        it "should accept 460 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.png")
          })
          @image.valid?.should be_true
        end

        it "should not accept 513 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.gif")
          })
          @image.valid?.should be_false
        end
      end

      describe "with >=500 validation" do
        before{ @image = ImageWidthMin500.new }
        it "should not accept 460 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.png")
          })
          @image.valid?.should be_false
        end

        it "should accept 513 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.gif")
          })
          @image.valid?.should be_true
        end
      end

      describe "with 500-600 validation" do
        before{ @image = ImageWidthMin500Max600.new }
        it "should not accept 460 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.png")
          })
          @image.valid?.should be_false
        end

        it "should accept 513 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.gif")
          })
          @image.valid?.should be_true
        end

        it "should not accept 725 image" do
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

