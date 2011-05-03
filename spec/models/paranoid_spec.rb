require 'spec_helper'

describe Paranoid, :mogilefs => true do
  before do
    @mg = MogileFS::MogileFS.new({ :domain => ActsAsImageStore.backend['domain'], :hosts  => ActsAsImageStore.backend['hosts'] })
  end

  context "saving" do
    before do
      @paranoid = Factory.build(:paranoid)
    end

    it "should return hash value when saved" do
      @paranoid.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.jpg"
      lambda{ @paranoid.save }.should_not raise_error
      @paranoid.image.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
      @mg.list_keys('').shift.should == ['bcadded5ee18bfa7c99834f307332b02.jpg']
    end

    it "should accept another image using set_image_data" do
      @paranoid.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.jpg"
      @paranoid.save!
      @paranoid = Factory.build(:paranoid)
      @paranoid.set_image_data :image, File.open("#{File.dirname(__FILE__)}/../sample.png").read
      lambda{ @paranoid.save }.should_not raise_error
      @paranoid.image.should == '60de57a8f5cd0a10b296b1f553cb41a9.png'
      @mg.list_keys('').shift.sort.should == ['60de57a8f5cd0a10b296b1f553cb41a9.png', 'bcadded5ee18bfa7c99834f307332b02.jpg']
      StoredImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 1
      StoredImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').refcount.should == 1
    end
  end

  context "deletion" do
    before do
      @paranoid = Factory.build(:paranoid)
      @paranoid.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.jpg"
      @paranoid.save!
    end

    it "should affect nothing on soft removal" do
      lambda{ @paranoid.destroy }.should_not raise_error
      @mg.list_keys('').shift.sort.should == ['bcadded5ee18bfa7c99834f307332b02.jpg']
      StoredImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 1
    end

    it "should decrease refcount when deleting duplicated image" do
      lambda do
        @paranoid.destroy
        @paranoid.reload.destroy
      end.should_not raise_error
      @mg.list_keys('').should be_nil
      StoredImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').should be_nil
    end

    it "should delete image data on real removal" do
      lambda{ @paranoid.destroy! }.should_not raise_error
      @mg.list_keys('').should be_nil
      StoredImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').should be_nil
    end
  end
end
