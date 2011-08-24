require 'spec_helper'

describe Multiple, :backend => true do
  context "saving" do
    before do
      @multiple = Factory.build(:multiple)
    end

    it "should return hash value when saved" do
      @multiple.add_image_file :photo, "#{File.dirname(__FILE__)}/../sample.jpg"
      @multiple.add_image_file :photo, "#{File.dirname(__FILE__)}/../sample.png"
      lambda{ @multiple.save! }.should_not raise_error
      @multiple.photos.map{|r| r.photo}.should == ['bcadded5ee18bfa7c99834f307332b02.jpg', '60de57a8f5cd0a10b296b1f553cb41a9.png']
      StoredImage.storage.list_keys('').should == ['bcadded5ee18bfa7c99834f307332b02.jpg', '60de57a8f5cd0a10b296b1f553cb41a9.png']
    end

    it "should report error with invalid image file" do
      @multiple.add_image_file :photo, "#{File.dirname(__FILE__)}/../spec_helper.rb"
      lambda{ @multiple.save! }.should raise_error ActiveRecord::RecordInvalid
      @multiple.errors[:base] = I18n.translate('acts_as_image_store.errors.messages.invalid_image')
      StoredImage.storage.list_keys('').should == []
    end

    it "should report error with unsupported image file" do
      @multiple.add_image_file :photo, "#{File.dirname(__FILE__)}/../sample.bmp"
      lambda{ @multiple.save! }.should raise_error ActiveRecord::RecordInvalid
      @multiple.errors[:base] = I18n.translate('acts_as_image_store.errors.messages.invalid_type')
      StoredImage.storage.list_keys('').should == []
    end
  end

  context "updating" do
    before do
      @multiple = Factory.build(:multiple)
      @multiple.add_image_file :photo, "#{File.dirname(__FILE__)}/../sample.jpg"
      @multiple.add_image_file :photo, "#{File.dirname(__FILE__)}/../sample.png"
      @multiple.save!
    end

    it "should be sortable" do
      @multiple.uploaded_photos = []
      @multiple.add_image_key :photo, '60de57a8f5cd0a10b296b1f553cb41a9.png'
      @multiple.add_image_key :photo, 'bcadded5ee18bfa7c99834f307332b02.jpg'
      lambda{ @multiple.save! }.should_not raise_error
      @multiple.photos.reload.map{|r| r.photo}.should == [
        '60de57a8f5cd0a10b296b1f553cb41a9.png',
        'bcadded5ee18bfa7c99834f307332b02.jpg',
      ]
    end

    it "should reduce refcount on update" do
      @multiple.uploaded_photos = []
      @multiple.add_image_key :photo, 'bcadded5ee18bfa7c99834f307332b02.jpg'
      lambda{ @multiple.save! }.should_not raise_error
      @multiple.photos.count.should == 1
      StoredImage.all.inject(0){|sum,r| sum + r.refcount }.should == 1
    end

    it "should accept another image file" do
      @multiple.add_image_data :photo, File.read("#{File.dirname(__FILE__)}/../sample.gif")
      lambda{ @multiple.save! }.should_not raise_error
      @multiple.photos.map{|r| r.photo}.should == [
        'bcadded5ee18bfa7c99834f307332b02.jpg',
        '60de57a8f5cd0a10b296b1f553cb41a9.png',
        '5d1e43dfd47173ae1420f061111e0776.gif'
      ]
    end

    it "should report error with invalid key" do
      @multiple.uploaded_photos = []
      @multiple.add_image_key :photo, '5d1e43dfd47173ae1420f061111e0776.gif'
      lambda{ @multiple.save! }.should raise_error ActiveRecord::RecordInvalid
      @multiple.errors[:base] = I18n.translate('acts_as_image_store.errors.messages.invalid_image_key')
    end
  end

  context "removal" do
    before do
      @multiple = Factory.build(:multiple)
      @multiple.add_image_file :photo, "#{File.dirname(__FILE__)}/../sample.jpg"
      @multiple.add_image_file :photo, "#{File.dirname(__FILE__)}/../sample.png"
      @multiple.save!
    end

    it "should reduce refcount on update" do
      @multiple.destroy
      MultiplePhoto.count.should == 0
      StoredImage.all.inject(0){|sum,r| sum + r.refcount }.should == 0
    end
  end
end
