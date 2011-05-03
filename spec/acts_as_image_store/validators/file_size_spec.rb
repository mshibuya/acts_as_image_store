# coding: utf-8
require 'spec_helper'

describe ActsAsImageStore do
  context "Validators" do
    context "FileSize" do
      describe "with <=20k validation" do
        before{ @image = ImageMax20.new }
        it "should accept 16k image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.png")
          })
          @image.valid?.should be_true
        end

        it "should not accept 30k image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_false
        end
      end

      describe "with >=20k validation" do
        before{ @image = ImageMin20.new }
        it "should not accept 16k image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.png")
          })
          @image.valid?.should be_false
        end

        it "should accept 30k image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_true
        end
      end

      describe "with 20k-40k validation" do
        before{ @image = ImageMin20Max40.new }
        it "should not accept 16k image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.png")
          })
          @image.valid?.should be_false
        end

        it "should accept 30k image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_true
        end

        it "should not accept 97k image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.jpg',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.jpg")
          })
          @image.valid?.should be_false
        end
      end

      describe "with <=20k validation of old form" do
        before{ @image = ImageMax20OldForm.new }
        it "should accept 16k image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.png")
          })
          @image.valid?.should be_true
        end

        it "should not accept 30k image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_false
        end
      end

      describe "with error message of <=20k validation" do
        before{ @image = ImageMax20.new }
        it "should not accept 30k image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_false
          @image.errors[:image].shift.should == 'must be smaller than 20KB.'
        end
      end

      describe "with ja error message of <=20k validation" do
        before do
          @image = ImageMax20.new
          I18n.locale = :ja
        end

        after do
          I18n.locale = I18n.default_locale
        end

        it "should not accept 30k image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_false
          @image.errors[:image].shift.should == 'は20KB以下でなければなりません。'
        end
      end

      describe "with custom error message of <=20k validation" do
        before{ @image = ImageMax20CustomMsg.new }
        it "should not accept 30k image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_false
          @image.errors[:image].shift.should == 'custom'
        end
      end
    end
  end
end

