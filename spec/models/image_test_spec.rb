require 'spec_helper'

describe ImageTest do
  include MogilefsHelperMethods

  it "should not accept file larger than maxsize" do
    image_test = ImageTest.new
    t = Tempfile.new('mogileimagetest')
    for i in 1..(1.megabytes)
      t << 'abcde'
    end
    t << 'f'
    t.size.should == 5.megabytes+1
    image_test.set_image_file :image, t
    image_test.valid?.should be_false
  end

  context "default validation" do
    before{ @image_test = ImageTest.new }
    it "should accept jpeg image" do
      @image_test.image = ActionDispatch::Http::UploadedFile.new({
        :filename => 'sample.jpg',
        :tempfile => File.open("#{File.dirname(__FILE__)}/../sample.jpg")
      })
      @image_test.valid?.should be_true
    end

    it "should accept gif image" do
      @image_test.image = ActionDispatch::Http::UploadedFile.new({
        :filename => 'sample.gif',
        :tempfile => File.open("#{File.dirname(__FILE__)}/../sample.gif")
      })
      @image_test.valid?.should be_true
    end

    it "should accept png image" do
      @image_test.image = ActionDispatch::Http::UploadedFile.new({
        :filename => 'sample.png',
        :tempfile => File.open("#{File.dirname(__FILE__)}/../sample.png")
      })
      @image_test.valid?.should be_true
    end

     it "should not accept bmp image" do
      @image_test.image = ActionDispatch::Http::UploadedFile.new({
        :filename => 'sample.bmp',
        :tempfile => File.open("#{File.dirname(__FILE__)}/../sample.bmp")
      })
      @image_test.valid?.should be_false
      @image_test.errors[:image].shift.should == "must be JPEG, GIF or PNG file."
    end

    it "should not accept text file" do
      @image_test.image = ActionDispatch::Http::UploadedFile.new({
        :filename => 'spec_helper.rb',
        :tempfile => File.open("#{File.dirname(__FILE__)}/../spec_helper.rb")
      })
      @image_test.valid?.should be_false
      @image_test.errors[:image].shift.should == "must be image file."
    end
  end

  context "MogileFS backend" do
    before(:all) { mogilefs_prepare }
    after(:all)  { mogilefs_cleanup }

    before do
      @mg = MogileFS::MogileFS.new({ :domain => MogileImageStore.backend['domain'], :hosts  => MogileImageStore.backend['hosts'] })
    end

    context "saving" do
      before do
        @image_test = Factory.build(:image_test)
      end

      it "should return hash value when saved" do
        @image_test.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.jpg"
        lambda{ @image_test.save }.should_not raise_error
        @image_test.image.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
        @mg.list_keys('').shift.should == ['bcadded5ee18bfa7c99834f307332b02.jpg']
      end

      it "should increase refcount when saving the same image" do
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 1
        @image_test.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.jpg"
        lambda{ @image_test.save }.should_not raise_error
        @image_test.image.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
        @mg.list_keys('').shift.should == ['bcadded5ee18bfa7c99834f307332b02.jpg']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 2
      end

      it "should accept another image using set_image_data" do
        @image_test.set_image_data :image, File.open("#{File.dirname(__FILE__)}/../sample.png").read
        lambda{ @image_test.save }.should_not raise_error
        @image_test.image.should == '60de57a8f5cd0a10b296b1f553cb41a9.png'
        @mg.list_keys('').shift.sort.should == ['60de57a8f5cd0a10b296b1f553cb41a9.png', 'bcadded5ee18bfa7c99834f307332b02.jpg']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 2
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').refcount.should == 1
      end
    end

    context "retrieval" do
      it "should return 2 urls" do
        sleep(3) # wait until replication becomes ready
        MogileImage.fetch_urls('bcadded5ee18bfa7c99834f307332b02', 'jpg').pop.should have(2).items
        MogileImage.fetch_urls('60de57a8f5cd0a10b296b1f553cb41a9', 'png').pop.should have(2).items
      end

      it "should return raw jpeg image" do
        content_type, data = MogileImage.fetch_data('bcadded5ee18bfa7c99834f307332b02', 'jpg')
        content_type.should == 'image/jpeg'
        img = ::Magick::Image.from_blob(data).shift
        img.format.should == 'JPEG'
        img.columns.should == 725
        img.rows.should == 544
        @mg.list_keys('').shift.sort.should == ['60de57a8f5cd0a10b296b1f553cb41a9.png', 'bcadded5ee18bfa7c99834f307332b02.jpg']
      end

      it "should return raw png image" do
        content_type, data = MogileImage.fetch_data('60de57a8f5cd0a10b296b1f553cb41a9', 'png')
        content_type.should == 'image/png'
        img = ::Magick::Image.from_blob(data).shift
        img.format.should == 'PNG'
        img.columns.should == 460
        img.rows.should == 445
        @mg.list_keys('').shift.sort.should == ['60de57a8f5cd0a10b296b1f553cb41a9.png', 'bcadded5ee18bfa7c99834f307332b02.jpg']
      end

      it "should return jpeg=>png converted image" do
        content_type, data = MogileImage.fetch_data('bcadded5ee18bfa7c99834f307332b02', 'png')
        content_type.should == 'image/png'
        img = ::Magick::Image.from_blob(data).shift
        img.format.should == 'PNG'
        img.columns.should == 725
        img.rows.should == 544
        @mg.list_keys('').shift.sort.should ==
          ['60de57a8f5cd0a10b296b1f553cb41a9.png', 'bcadded5ee18bfa7c99834f307332b02.jpg', 'bcadded5ee18bfa7c99834f307332b02.png']
      end

      it "should return resized jpeg image" do
        content_type, data = MogileImage.fetch_data('bcadded5ee18bfa7c99834f307332b02', 'jpg', '600x450')
        content_type.should == 'image/jpeg'
        img = ::Magick::Image.from_blob(data).shift
        img.format.should == 'JPEG'
        img.columns.should == 600
        img.rows.should == 450
        @mg.list_keys('').shift.sort.should ==
          ['60de57a8f5cd0a10b296b1f553cb41a9.png', 'bcadded5ee18bfa7c99834f307332b02.jpg',
           'bcadded5ee18bfa7c99834f307332b02.jpg/600x450', 'bcadded5ee18bfa7c99834f307332b02.png']
      end

      it "should return raw jpeg image when requested larger size" do
        content_type, data = MogileImage.fetch_data('bcadded5ee18bfa7c99834f307332b02', 'jpg', '800x600')
        content_type.should == 'image/jpeg'
        img = ::Magick::Image.from_blob(data).shift
        img.format.should == 'JPEG'
        img.columns.should == 725
        img.rows.should == 544
        @mg.list_keys('').shift.sort.should ==
          ['60de57a8f5cd0a10b296b1f553cb41a9.png', 'bcadded5ee18bfa7c99834f307332b02.jpg',
           'bcadded5ee18bfa7c99834f307332b02.jpg/600x450', 'bcadded5ee18bfa7c99834f307332b02.png']
      end

      it "should return filled jpeg image" do
        content_type, data = MogileImage.fetch_data('bcadded5ee18bfa7c99834f307332b02', 'jpg', '80x80fill')
        content_type.should == 'image/jpeg'
        img = ::Magick::Image.from_blob(data).shift
        img.format.should == 'JPEG'
        img.columns.should == 80
        img.rows.should == 80
        dark = ::Magick::Pixel.from_color('#070707').intensity
        img.pixel_color(40, 0).intensity.should < dark
        img.pixel_color(40,79).intensity.should < dark
        img.pixel_color( 0,40).intensity.should > dark
        img.pixel_color(79,40).intensity.should > dark
        @mg.list_keys('').shift.sort.should ==
          ['60de57a8f5cd0a10b296b1f553cb41a9.png',
           'bcadded5ee18bfa7c99834f307332b02.jpg',
           'bcadded5ee18bfa7c99834f307332b02.jpg/600x450',
           'bcadded5ee18bfa7c99834f307332b02.jpg/80x80fill',
           'bcadded5ee18bfa7c99834f307332b02.png']
      end

      it "should return filled jpeg image" do
        content_type, data = MogileImage.fetch_data('bcadded5ee18bfa7c99834f307332b02', 'jpg', '80x80fill2')
        content_type.should == 'image/jpeg'
        img = ::Magick::Image.from_blob(data).shift
        img.format.should == 'JPEG'
        img.columns.should == 80
        img.rows.should == 80
        dark = ::Magick::Pixel.from_color('#070707').intensity
        img.pixel_color(40, 0).intensity.should < dark
        img.pixel_color(40,79).intensity.should < dark
        img.pixel_color( 0,40).intensity.should < dark
        img.pixel_color(79,40).intensity.should < dark
        img.pixel_color(40, 2).intensity.should < dark
        img.pixel_color(40,77).intensity.should < dark
        img.pixel_color( 2,40).intensity.should > dark
        img.pixel_color(77,40).intensity.should > dark
        @mg.list_keys('').shift.sort.should ==
          ['60de57a8f5cd0a10b296b1f553cb41a9.png',
           'bcadded5ee18bfa7c99834f307332b02.jpg',
           'bcadded5ee18bfa7c99834f307332b02.jpg/600x450',
           'bcadded5ee18bfa7c99834f307332b02.jpg/80x80fill',
           'bcadded5ee18bfa7c99834f307332b02.jpg/80x80fill2',
           'bcadded5ee18bfa7c99834f307332b02.png']
      end

      it "should raise error when size is not allowed" do
        lambda{ MogileImage.fetch_urls('bcadded5ee18bfa7c99834f307332b02', 'jpg', '83x60') }.should raise_error MogileImageStore::SizeNotAllowed
        lambda{ MogileImage.fetch_urls('bcadded5ee18bfa7c99834f307332b02', 'jpg', '80x60fill') }.should raise_error MogileImageStore::SizeNotAllowed
        lambda{ MogileImage.fetch_urls('bcadded5ee18bfa7c99834f307332b02', 'jpg', '800x604') }.should raise_error MogileImageStore::SizeNotAllowed
      end

      it "should return existence of keys" do
        MogileImage.key_exist?('60de57a8f5cd0a10b296b1f553cb41a9.png').should be_true
        MogileImage.key_exist?('5d1e43dfd47173ae1420f061111e0776.gif').should be_false
        MogileImage.key_exist?([
          '60de57a8f5cd0a10b296b1f553cb41a9.png',
          '60de57a8f5cd0a10b296b1f553cb41a9.png',
          'bcadded5ee18bfa7c99834f307332b02.jpg',
        ]).should be_true
        MogileImage.key_exist?([
          '60de57a8f5cd0a10b296b1f553cb41a9.png',
          '5d1e43dfd47173ae1420f061111e0776.gif',
        ]).should be_false
      end
    end

    context "overwriting" do
      it "should delete old image when overwritten" do
        @image_test = ImageTest.find_by_image('60de57a8f5cd0a10b296b1f553cb41a9.png')
        @image_test.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.gif"
        lambda{ @image_test.save }.should_not raise_error
        @image_test.image.should == '5d1e43dfd47173ae1420f061111e0776.gif'
        @mg.list_keys('').shift.sort.should ==
          ['5d1e43dfd47173ae1420f061111e0776.gif',
           'bcadded5ee18bfa7c99834f307332b02.jpg',
           'bcadded5ee18bfa7c99834f307332b02.jpg/600x450',
           'bcadded5ee18bfa7c99834f307332b02.jpg/80x80fill',
           'bcadded5ee18bfa7c99834f307332b02.jpg/80x80fill2',
           'bcadded5ee18bfa7c99834f307332b02.png']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 2
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').should be_nil
        MogileImage.find_by_name('5d1e43dfd47173ae1420f061111e0776').refcount.should == 1
      end
    end

    context "saving without uploading image" do
      it "should preserve image name" do
        @image_test = ImageTest.find_by_image('5d1e43dfd47173ae1420f061111e0776.gif')
        new_name = @image_test.name + ' new'
        @image_test.name = new_name
        MogileImage.should_not_receive(:save_image)
        lambda{ @image_test.save }.should_not raise_error
        @image_test.name.should == new_name
        @image_test.image.should == '5d1e43dfd47173ae1420f061111e0776.gif'
        @mg.list_keys('').shift.sort.should ==
          ['5d1e43dfd47173ae1420f061111e0776.gif',
           'bcadded5ee18bfa7c99834f307332b02.jpg',
           'bcadded5ee18bfa7c99834f307332b02.jpg/600x450',
           'bcadded5ee18bfa7c99834f307332b02.jpg/80x80fill',
           'bcadded5ee18bfa7c99834f307332b02.jpg/80x80fill2',
           'bcadded5ee18bfa7c99834f307332b02.png']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 2
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').should be_nil
        MogileImage.find_by_name('5d1e43dfd47173ae1420f061111e0776').refcount.should == 1
      end

      it "should preserve image name with image_type validation" do
        @image_test = ImageTestWithImageType.first
        @image_test.image.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
        new_name = @image_test.name + ' imagetype'
        @image_test.valid?.should be_true
      end

      it "should preserve image name with file_size validation" do
        @image_test = ImageTestWithFileSize.first
        @image_test.image.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
        new_name = @image_test.name + ' filesize'
        @image_test.valid?.should be_true
      end

      it "should preserve image name with width validation" do
        @image_test = ImageTestWithWidth.first
        @image_test.image.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
        new_name = @image_test.name + ' width'
        @image_test.valid?.should be_true
      end

      it "should preserve image name with height validation" do
        @image_test = ImageTestWithHeight.first
        @image_test.image.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
        new_name = @image_test.name + ' height'
        @image_test.valid?.should be_true
      end
    end

    context "deletion" do
      before do
        @image_test = ImageTest.first
      end

      it "should decrease refcount when deleting duplicated image" do
        lambda{ @image_test.destroy }.should_not raise_error
        @mg.list_keys('').shift.sort.should ==
          ['5d1e43dfd47173ae1420f061111e0776.gif',
           'bcadded5ee18bfa7c99834f307332b02.jpg',
           'bcadded5ee18bfa7c99834f307332b02.jpg/600x450',
           'bcadded5ee18bfa7c99834f307332b02.jpg/80x80fill',
           'bcadded5ee18bfa7c99834f307332b02.jpg/80x80fill2',
           'bcadded5ee18bfa7c99834f307332b02.png']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 1
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').should be_nil
        MogileImage.find_by_name('5d1e43dfd47173ae1420f061111e0776').refcount.should == 1
      end

      it "should delete image data when deleting image" do
        lambda{ @image_test.destroy }.should_not raise_error
        @mg.list_keys('').shift.should == ['5d1e43dfd47173ae1420f061111e0776.gif']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').should be_nil
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').should be_nil
        MogileImage.find_by_name('5d1e43dfd47173ae1420f061111e0776').refcount.should == 1
      end
    end

    context "saving image without model" do
      it "should save image and return key" do
        key = MogileImage.store_image(File.open("#{File.dirname(__FILE__)}/../sample.png").read)
        key.should == '60de57a8f5cd0a10b296b1f553cb41a9.png'
        @mg.list_keys('').shift.should == [
          '5d1e43dfd47173ae1420f061111e0776.gif',
          '60de57a8f5cd0a10b296b1f553cb41a9.png'
        ]
      end

      it "should raise error with invalid data" do
        lambda do
          MogileImage.store_image('abc')
        end.should raise_error MogileImageStore::InvalidImage
      end
    end

    context "jpeg exif" do
      it "should clear exif data" do
        @image_test = Factory.build(:image_test)
        @image_test.set_image_file :image, "#{File.dirname(__FILE__)}/../sample_exif.jpg"
        lambda{ @image_test.save }.should_not raise_error
        content_type, data = MogileImage.fetch_data(@image_test.image.split('.').first, 'jpg', 'raw')
        imglist = Magick::ImageList.new
        imglist.from_blob(data)
        imglist.first.get_exif_by_entry().should == []
      end
      it "should keep exif data" do
        @image_test = Factory.build(:keep_exif)
        @image_test.set_image_file :image, "#{File.dirname(__FILE__)}/../sample_exif.jpg"
        lambda{ @image_test.save }.should_not raise_error
        content_type, data = MogileImage.fetch_data(@image_test.image.split('.').first, 'jpg', 'raw')
        imglist = Magick::ImageList.new
        imglist.from_blob(data)
        imglist.first.get_exif_by_entry().should_not == []
      end
    end

    context "huge image" do
      it "should be shrinked to fit within limit" do
        @image_test = Factory.build(:image_test)
        @image_test.set_image_file :image, "#{File.dirname(__FILE__)}/../sample_huge.gif"
        lambda{ @image_test.save }.should_not raise_error
        content_type, data = MogileImage.fetch_data(@image_test.image.split('.').first, 'jpg', 'raw')
        imglist = Magick::ImageList.new
        imglist.from_blob(data)
        imglist.first.columns.should == 2048
        imglist.first.rows.should == 1536
      end
    end
  end
end
