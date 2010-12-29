# coding: utf-8
require 'spec_helper'

describe MogileImageStore do
  context "Validators" do
    context "ImageType" do
      describe "with image validation" do
        before{ @image = ImageAll.new }
        it "should accept jpeg image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.jpg',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.jpg")
          })
          @image.valid?.should be_true
        end

        it "should accept gif image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_true
        end

        it "should accept png image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.png")
          })
          @image.valid?.should be_true
        end

        it "should not accept text file" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'spec_helper.rb',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../spec_helper.rb")
          })
          @image.valid?.should be_false
        end
      end

      describe "with jpeg validation" do
        before{ @image = ImageJpeg.new }
        it "should accept jpeg image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.jpg',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.jpg")
          })
          @image.valid?.should be_true
        end

        it "should not accept gif image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_false
        end

        it "should not accept png image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.png")
          })
          @image.valid?.should be_false
        end
      end

      describe "with gif validation" do
        before{ @image = ImageGif.new }
        it "should not accept jpeg image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.jpg',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.jpg")
          })
          @image.valid?.should be_false
        end

        it "should accept gif image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_true
        end

        it "should not accept png image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.png")
          })
          @image.valid?.should be_false
        end
      end

      describe "with png validation" do
        before{ @image = ImagePng.new }
        it "should not accept jpeg image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.jpg',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.jpg")
          })
          @image.valid?.should be_false
        end

        it "should not accept gif image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_false
        end

        it "should accept png image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.png")
          })
          @image.valid?.should be_true
        end
      end

      describe "with jpeg|png validation" do
        before{ @image = ImageJpegPng.new }
        it "should accept jpeg image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.jpg',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.jpg")
          })
          @image.valid?.should be_true
        end

        it "should not accept gif image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.gif',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.gif")
          })
          @image.valid?.should be_false
        end

        it "should accept png image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.png',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.png")
          })
          @image.valid?.should be_true
        end
      end

      describe "with old form image validation" do
        before{ @image = ImageAllOldForm.new }
        it "should accept jpeg image" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'sample.jpg',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../sample.jpg")
          })
          @image.valid?.should be_true
        end

        it "should not accept text file" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'spec_helper.rb',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../spec_helper.rb")
          })
          @image.valid?.should be_false
        end
      end

      describe "with error message of image validation" do
        before{ @image = ImageAll.new }
        it "should not accept text file" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'spec_helper.rb',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../spec_helper.rb")
          })
          @image.valid?.should be_false
          @image.errors[:image].shift.should be == 'must be JPEG, GIF or PNG file.'
        end
      end

      describe "with ja error message of image validation" do
        before do
          @image = ImageAll.new
          I18n.locale = :ja
        end

        after do
          I18n.locale = I18n.default_locale
        end

        it "should not accept text file" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'spec_helper.rb',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../spec_helper.rb")
          })
          @image.valid?.should be_false
          @image.errors[:image].shift.should be == 'はJPEG,GIFまたはPNGファイルでなければなりません。'
        end
      end

      describe "with custom error message of image validation" do
        before{ @image = ImageAllCustomMsg.new }
        it "should not accept text file" do
          @image.image = ActionDispatch::Http::UploadedFile.new({
            :filename => 'spec_helper.rb',
            :tempfile => File.open("#{File.dirname(__FILE__)}/../../spec_helper.rb")
          })
          @image.valid?.should be_false
          @image.errors[:image].shift.should be == 'custom'
        end
      end
    end
  end
end

