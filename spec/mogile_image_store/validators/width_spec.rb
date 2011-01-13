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
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.png")
          })
          @image.valid?.should be_true
        end

        it "should not accept 513 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_false
        end
      end

      describe "with >=500 validation" do
        before{ @image = ImageWidthMin500.new }
        it "should not accept 460 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.png")
          })
          @image.valid?.should be_false
        end

        it "should accept 513 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_true
        end
      end

      describe "with 500-600 validation" do
        before{ @image = ImageWidthMin500Max600.new }
        it "should not accept 460 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.png")
          })
          @image.valid?.should be_false
        end

        it "should accept 513 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_true
        end

        it "should not accept 725 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.jpg',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.jpg")
          })
          @image.valid?.should be_false
        end
      end

      describe "with <=500 validation of old form" do
        before{ @image = ImageWidthMax500OldForm.new }
        it "should accept 460 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.png")
          })
          @image.valid?.should be_true
        end

        it "should not accept 513 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_false
        end
      end

      describe "with error message of <=500 validation" do
        before{ @image = ImageWidthMax500.new }
        it "should not accept 513 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_false
          @image.errors[:image].shift.should be == '\'s width must be smaller than 500 pixels.'
        end
      end

      describe "with error message of <=500 validation" do
        before do
          @image = ImageWidthMax500.new
          I18n.locale = :ja
        end

        after do
          I18n.locale = I18n.default_locale
        end

        it "should not accept 513 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_false
          @image.errors[:image].shift.should be == 'の幅は500pixel以下でなければなりません。'
        end
      end

      describe "with custom error message of <=500 validation" do
        before{ @image = ImageWidthMax500CustomMsg.new }
        it "should not accept 513 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_false
          @image.errors[:image].shift.should be == 'custom'
        end
      end

      describe "with ==513 validation" do
        before{ @image = ImageWidth513.new }
        it "should not accept 460 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.png")
          })
          @image.valid?.should be_false
        end

        it "should accept 513 image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_true
        end
      end
    end
  end
end

