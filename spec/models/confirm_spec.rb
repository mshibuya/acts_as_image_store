require 'spec_helper'
require 'mogilefs'

describe Confirm do
  context "MogileFS backend" do
    before(:all) do
      #prepare mogilefs
      @mogadm = MogileFS::Admin.new :hosts  => MogileImageStore.backend['hosts']
      unless @mogadm.get_domains[MogileImageStore.backend['domain']]
        @mogadm.create_domain MogileImageStore.backend['domain']
        @mogadm.create_class  MogileImageStore.backend['domain'], MogileImageStore.backend['class'], 2 rescue nil
      end
      MogileImageStore.options[:upload_cache] = 1
    end

    before do
      @mg = MogileFS::MogileFS.new({ :domain => MogileImageStore.backend['domain'], :hosts  => MogileImageStore.backend['hosts'] })
    end

    context "saving" do
      before do
        @confirm = Factory.build(:confirm)
      end

      it "should return hash value when saved" do
        @confirm.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.jpg"
        @confirm.valid?.should be_true
        @confirm.image.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
        @mg.list_keys('').shift.should == ['bcadded5ee18bfa7c99834f307332b02.jpg']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 0
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').keep_till.should_not be_nil
        lambda{ @confirm.save! }.should_not raise_error
        @confirm.image.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 1
      end

      it "should increase refcount when saving the same image" do
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 1
        @confirm.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.jpg"
        @confirm.valid?.should be_true
        @confirm.image.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
        @mg.list_keys('').shift.should == ['bcadded5ee18bfa7c99834f307332b02.jpg']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 1
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').keep_till.should_not be_nil
        lambda{ @confirm.save! }.should_not raise_error
        @confirm.image.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 2
      end

      it "should raise error when upload cache was cleared" do
        @confirm.set_image_data :image, File.open("#{File.dirname(__FILE__)}/../sample.png").read
        @confirm.valid?.should be_true
        @confirm.image.should == '60de57a8f5cd0a10b296b1f553cb41a9.png'
        @mg.list_keys('').shift.sort.should == ['60de57a8f5cd0a10b296b1f553cb41a9.png', 'bcadded5ee18bfa7c99834f307332b02.jpg']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 2
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').refcount.should == 0
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').keep_till.should_not be_nil
        sleep(1)
        MogileImage.cleanup_temporary_image
        lambda{ @confirm.save! }.should raise_error
        @confirm.image.should == '60de57a8f5cd0a10b296b1f553cb41a9.png'
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 2
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').should be_nil
      end

      it "should accept another image using set_image_data" do
        @confirm.set_image_data :image, File.open("#{File.dirname(__FILE__)}/../sample.png").read
        @confirm.valid?.should be_true
        @confirm.image.should == '60de57a8f5cd0a10b296b1f553cb41a9.png'
        @mg.list_keys('').shift.sort.should == ['60de57a8f5cd0a10b296b1f553cb41a9.png', 'bcadded5ee18bfa7c99834f307332b02.jpg']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 2
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').refcount.should == 0
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').keep_till.should_not be_nil
        lambda{ @confirm.save! }.should_not raise_error
        @confirm.image.should == '60de57a8f5cd0a10b296b1f553cb41a9.png'
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 2
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').refcount.should == 1
        sleep(1)
        MogileImage.cleanup_temporary_image
      end
    end

    context "overwriting" do
      it "should delete old image when overwritten" do
        @confirm = Confirm.find_by_image('60de57a8f5cd0a10b296b1f553cb41a9.png')
        @confirm.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.gif"
        @confirm.valid?.should be_true
        @confirm.image.should == '5d1e43dfd47173ae1420f061111e0776.gif'
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').refcount.should == 1
        MogileImage.find_by_name('5d1e43dfd47173ae1420f061111e0776').refcount.should == 0
        lambda{ @confirm.save }.should_not raise_error
        @confirm.image.should == '5d1e43dfd47173ae1420f061111e0776.gif'
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').should be_nil
        MogileImage.find_by_name('5d1e43dfd47173ae1420f061111e0776').refcount.should == 1
        @mg.list_keys('').shift.sort.should ==
          ['5d1e43dfd47173ae1420f061111e0776.gif', 'bcadded5ee18bfa7c99834f307332b02.jpg']
      end
    end

    context "saving without uploading image" do
      it "should preserve image name" do
        @confirm = Confirm.find_by_image('5d1e43dfd47173ae1420f061111e0776.gif')
        new_name = @confirm.name + ' new'
        @confirm.name = new_name
        @confirm.valid?.should be_true
        @confirm.name.should == new_name
        @confirm.image.should == '5d1e43dfd47173ae1420f061111e0776.gif'
        lambda{ @confirm.save }.should_not raise_error
        @confirm.name.should == new_name
        @confirm.image.should == '5d1e43dfd47173ae1420f061111e0776.gif'
        @mg.list_keys('').shift.sort.should ==
          ['5d1e43dfd47173ae1420f061111e0776.gif', 'bcadded5ee18bfa7c99834f307332b02.jpg']
        MogileImage.find_by_name('5d1e43dfd47173ae1420f061111e0776').refcount.should == 1
      end
    end

    context "deletion" do
      it "should keep record with refcount = 0 when deleting non-expired image" do
        @confirm = Confirm.find_by_image('5d1e43dfd47173ae1420f061111e0776.gif')
        lambda{ @confirm.destroy }.should_not raise_error
        @mg.list_keys('').shift.sort.should ==
          ['5d1e43dfd47173ae1420f061111e0776.gif', 'bcadded5ee18bfa7c99834f307332b02.jpg']
        MogileImage.find_by_name('5d1e43dfd47173ae1420f061111e0776').refcount.should == 0
      end

      it "should delete image data when expired" do
        sleep(1)
        MogileImage.cleanup_temporary_image
        @mg.list_keys('').shift.sort.should == ['bcadded5ee18bfa7c99834f307332b02.jpg']
        MogileImage.find_by_name('5d1e43dfd47173ae1420f061111e0776').should be_nil
      end
    end

    after(:all) do
      #cleanup
      MogileImage.destroy_all
      @mogadm = MogileFS::Admin.new :hosts  => MogileImageStore.backend['hosts']
      @mg = MogileFS::MogileFS.new({ :domain => MogileImageStore.backend['domain'], :hosts  => MogileImageStore.backend['hosts'] })
      @mg.each_key('') {|k| @mg.delete k }
      @mogadm.delete_domain MogileImageStore.backend['domain']
    end

  end
end
