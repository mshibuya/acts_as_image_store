# coding: utf-8
require 'spec_helper'

describe MogileImageStore do
  context "Validators" do
    context "FileSize" do
      describe "with <=20k validation" do
        before{ @image = ImageMaxTwenty.new }
        it "should accept 16k image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.png")
          })
          @image.valid?.should be_true
        end

        it "should not accept 30k image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.gif")
          })
          @image.valid?.should be_false
        end
      end

      describe "with >=20k validation" do
        before{ @image = ImageMinTwenty.new }
        it "should not accept 16k image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.png")
          })
          @image.valid?.should be_false
        end

        it "should accept 30k image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.gif")
          })
          @image.valid?.should be_true
        end
      end

      describe "with 20k-40k validation" do
        before{ @image = ImageMinTwentyMaxFourty.new }
        it "should not accept 16k image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.png")
          })
          @image.valid?.should be_false
        end

        it "should accept 30k image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../../sample.gif")
          })
          @image.valid?.should be_true
        end

        it "should not accept 97k image" do
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

