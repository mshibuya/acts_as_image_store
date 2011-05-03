require 'spec_helper'

describe Confirm, :mogilefs => true do
  before(:all) do
    @prev_cache_time = ActsAsImageStore.options[:upload_cache]
    ActsAsImageStore.options[:upload_cache] = 1
  end
  after(:all) do
    ActsAsImageStore.options[:upload_cache] = @prev_cache_time
  end

  before do
    @mg = MogileFS::MogileFS.new({ :domain => ActsAsImageStore.backend['domain'], :hosts  => ActsAsImageStore.backend['hosts'] })
    @confirm = Factory.build(:confirm)
  end

  context "saving" do
    it "should return hash value when saved" do
      @confirm.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.jpg"
      @confirm.valid?.should be_true
      @confirm.image.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
      @mg.list_keys('').shift.should == ['bcadded5ee18bfa7c99834f307332b02.jpg']
      StoredImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 0
      StoredImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').keep_till.should_not be_nil
      sleep(1)
      lambda{ @confirm.save! }.should_not raise_error
      @confirm.image.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
      StoredImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 1
    end

    it "should increase refcount when saving the same image" do
      @confirm.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.jpg"
      @confirm.save!
      @confirm = Factory.build(:confirm)
      StoredImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 1
      @confirm.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.jpg"
      @confirm.valid?.should be_true
      @mg.list_keys('').shift.should == ['bcadded5ee18bfa7c99834f307332b02.jpg']
      StoredImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 1
      StoredImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').keep_till.should_not be_nil
      lambda{ @confirm.save! }.should_not raise_error
      @confirm.image.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
      StoredImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 2
    end

    it "should not be valid when upload cache was cleared" do
      @confirm.set_image_data :image, File.open("#{File.dirname(__FILE__)}/../sample.png").read
      @confirm.valid?.should be_true
      StoredImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').refcount.should == 0
      StoredImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').keep_till.should_not be_nil
      sleep(1)
      StoredImage.cleanup_temporary_image
      @confirm.valid?.should be_false
      @confirm.errors[:image].should == ["has been expired. Please upload again."]
      @confirm.image.should be_nil
      StoredImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').should be_nil
    end

    it "should accept another image using set_image_data" do
      @confirm.set_image_data :image, File.open("#{File.dirname(__FILE__)}/../sample.png").read
      sleep(1)
      StoredImage.cleanup_temporary_image
      @confirm = Factory.build(:confirm)
      @confirm.set_image_data :image, File.open("#{File.dirname(__FILE__)}/../sample.png").read
      @confirm.valid?.should be_true
      @confirm.image.should == '60de57a8f5cd0a10b296b1f553cb41a9.png'
      @mg.list_keys('').shift.sort.should == ['60de57a8f5cd0a10b296b1f553cb41a9.png']
      StoredImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').refcount.should == 0
      StoredImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').keep_till.should_not be_nil
      lambda{ @confirm.save! }.should_not raise_error
      @confirm.image.should == '60de57a8f5cd0a10b296b1f553cb41a9.png'
      StoredImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').refcount.should == 1
    end
  end

  context "overwriting" do
    it "should delete old image when overwritten" do
      @confirm.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.png"
      @confirm.save!
      sleep(1)
      @confirm.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.gif"
      @confirm.valid?.should be_true
      @confirm.image.should == '5d1e43dfd47173ae1420f061111e0776.gif'
      StoredImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').refcount.should == 1
      StoredImage.find_by_name('5d1e43dfd47173ae1420f061111e0776').refcount.should == 0
      lambda{ @confirm.save }.should_not raise_error
      @confirm.image.should == '5d1e43dfd47173ae1420f061111e0776.gif'
      StoredImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').should be_nil
      StoredImage.find_by_name('5d1e43dfd47173ae1420f061111e0776').refcount.should == 1
      @mg.list_keys('').shift.sort.should ==
        ['5d1e43dfd47173ae1420f061111e0776.gif']
    end
  end

  context "saving without uploading image" do
    it "should preserve image name" do
      @confirm.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.gif"
      @confirm.save
      new_name = @confirm.name + ' new'
      @confirm.name = new_name
      @confirm.valid?.should be_true
      @confirm.name.should == new_name
      @confirm.image.should == '5d1e43dfd47173ae1420f061111e0776.gif'
      StoredImage.should_not_receive(:commit_image)
      lambda{ @confirm.save }.should_not raise_error
      @confirm.name.should == new_name
      @confirm.image.should == '5d1e43dfd47173ae1420f061111e0776.gif'
      @mg.list_keys('').shift.sort.should == ['5d1e43dfd47173ae1420f061111e0776.gif']
      StoredImage.find_by_name('5d1e43dfd47173ae1420f061111e0776').refcount.should == 1
    end
  end

  context "deletion" do
    it "should keep record with refcount = 0 when deleting non-expired image" do
      @confirm.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.gif"
      @confirm.save
      lambda{ @confirm.destroy }.should_not raise_error
      @mg.list_keys('').shift.sort.should == ['5d1e43dfd47173ae1420f061111e0776.gif']
      StoredImage.find_by_name('5d1e43dfd47173ae1420f061111e0776').refcount.should == 0
    end

    it "should delete image data when expired" do
      @confirm.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.gif"
      @confirm.save
      @confirm.destroy
      sleep(1)
      StoredImage.cleanup_temporary_image
      @mg.list_keys('').should be_nil
      StoredImage.all.should == []
    end
  end
end
