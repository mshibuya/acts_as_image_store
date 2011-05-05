require 'spec_helper'

describe Multiple, :backend => true do
  context "saving" do
    before do
      @multiple = Factory.build(:multiple)
    end

    it "should return hash value when saved" do
      @multiple.set_image_file :banner1, "#{File.dirname(__FILE__)}/../sample.jpg"
      @multiple.set_image_file :banner2, "#{File.dirname(__FILE__)}/../sample.png"
      lambda{ @multiple.save! }.should_not raise_error
      @multiple.banner1.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
      @multiple.banner2.should == '60de57a8f5cd0a10b296b1f553cb41a9.png'
      StoredImage.storage.list_keys('').sort.should == ['60de57a8f5cd0a10b296b1f553cb41a9.png', 'bcadded5ee18bfa7c99834f307332b02.jpg']
    end

    it "should increase refcount when saving the same image" do
      @multiple.set_image_file :banner1, "#{File.dirname(__FILE__)}/../sample.jpg"
      @multiple.set_image_file :banner2, "#{File.dirname(__FILE__)}/../sample.png"
      @multiple.save!
      StoredImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 1
      @multiple = Factory.build(:multiple)
      @multiple.set_image_file :banner2, "#{File.dirname(__FILE__)}/../sample.jpg"
      lambda{ @multiple.save }.should_not raise_error
      @multiple.banner2.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
      StoredImage.storage.list_keys('').sort.should == ['60de57a8f5cd0a10b296b1f553cb41a9.png', 'bcadded5ee18bfa7c99834f307332b02.jpg']
      StoredImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 2
      StoredImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').refcount.should == 1
    end
  end

  context "deletion" do
    before do
      @multiple1 = Factory.build(:multiple)
      @multiple1.set_image_file :banner1, "#{File.dirname(__FILE__)}/../sample.jpg"
      @multiple1.set_image_file :banner2, "#{File.dirname(__FILE__)}/../sample.png"
      @multiple1.save!
      @multiple2 = Factory.build(:multiple)
      @multiple2.set_image_file :banner2, "#{File.dirname(__FILE__)}/../sample.jpg"
      @multiple2.save!
    end

    it "should decrease refcount when deleting duplicated image" do
      lambda{ @multiple1.destroy }.should_not raise_error
      StoredImage.storage.list_keys('').sort.should == ['bcadded5ee18bfa7c99834f307332b02.jpg',]
      StoredImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 1
      StoredImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').should be_nil
    end

    it "should delete image data when deleting image" do
      @multiple1.destroy
      lambda{ @multiple2.destroy }.should_not raise_error
      StoredImage.storage.list_keys('').should be_nil
      StoredImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').should be_nil
      StoredImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').should be_nil
    end
  end
end
