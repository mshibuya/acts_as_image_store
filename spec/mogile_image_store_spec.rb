require 'spec_helper'
require 'mogilefs'

describe MogileImageStore do
  it "should be valid" do
    MogileImageStore.should be_a(Module)
  end

  it "should be configured" do
    MogileImageStore::Engine.config.mount_at.should_not be_nil
    MogileImageStore::Engine.config.mogile_fs.should_not be_nil
    MogileImageStore.config.should_not be_nil
  end

  context "MogileFS backend" do
    before(:all) do
      #prepare mogilefs
      @mogadm = MogileFS::Admin.new :hosts  => MogileImageStore.config[:hosts]
      unless @mogadm.get_domains[MogileImageStore.config[:domain]]
        @mogadm.create_domain MogileImageStore.config[:domain]
        @mogadm.create_class  MogileImageStore.config[:domain], MogileImageStore.config[:class], 2 rescue nil
      end
    end

    before do
      @mg = MogileFS::MogileFS.new({ :domain => MogileImageStore.config[:domain], :hosts  => MogileImageStore.config[:hosts] })
    end

    context "saving" do
      before do
        @image_test = Factory.build(:image_test)
      end

      it "should return hash value when saved" do
        @image_test.set_image_file :image, "#{File.dirname(__FILE__)}/sample.jpg"
        lambda{ @image_test.save }.should_not raise_error
        @image_test.image.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
        @mg.list_keys('').shift.should == ['bcadded5ee18bfa7c99834f307332b02.jpg']
      end

      it "should increase refcount when saving the same image" do
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 1
        @image_test.set_image_file :image, "#{File.dirname(__FILE__)}/sample.jpg"
        lambda{ @image_test.save }.should_not raise_error
        @image_test.image.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
        @mg.list_keys('').shift.should == ['bcadded5ee18bfa7c99834f307332b02.jpg']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 2
      end

      it "should accept another image" do
        @image_test.set_image_file :image, "#{File.dirname(__FILE__)}/sample.png"
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
        MogileImage.fetch_urls('bcadded5ee18bfa7c99834f307332b02').pop.should have(2).items
        MogileImage.fetch_urls('60de57a8f5cd0a10b296b1f553cb41a9').pop.should have(2).items
      end

      it "should return raw jpeg image" do
        content_type, data = MogileImage.fetch_data('bcadded5ee18bfa7c99834f307332b02')
        content_type.should == 'image/jpeg'
        img = ::Magick::Image.from_blob(data).shift
        img.format.should == 'JPEG'
        img.columns.should == 725
        img.rows.should == 544
        @mg.list_keys('').shift.sort.should == ['60de57a8f5cd0a10b296b1f553cb41a9.png', 'bcadded5ee18bfa7c99834f307332b02.jpg']
      end

      it "should return raw png image" do
        content_type, data = MogileImage.fetch_data('60de57a8f5cd0a10b296b1f553cb41a9')
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
    end

    context "deletion" do
      before do
        @image_test = ImageTest.first
      end

      it "should decrease refcount when deleting duplicated image" do
        lambda{ @image_test.destroy }.should_not raise_error
        @mg.list_keys('').shift.sort.should ==
          ['60de57a8f5cd0a10b296b1f553cb41a9.png', 'bcadded5ee18bfa7c99834f307332b02.jpg',
           'bcadded5ee18bfa7c99834f307332b02.jpg/600x450', 'bcadded5ee18bfa7c99834f307332b02.png']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 1
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').refcount.should == 1
      end

      it "should delete image data when deleting image" do
        lambda{ @image_test.destroy }.should_not raise_error
        @mg.list_keys('').shift.should == ['60de57a8f5cd0a10b296b1f553cb41a9.png']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').should be_nil
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').refcount.should == 1
      end
    end

    after(:all) do
      #cleanup
      @mogadm = MogileFS::Admin.new :hosts  => MogileImageStore.config[:hosts]
      @mg = MogileFS::MogileFS.new({ :domain => MogileImageStore.config[:domain], :hosts  => MogileImageStore.config[:hosts] })
      @mg.each_key('') {|k| @mg.delete k }
      @mogadm.delete_domain MogileImageStore.config[:domain]
    end

  end
end
