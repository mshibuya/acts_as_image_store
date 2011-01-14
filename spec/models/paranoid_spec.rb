require 'spec_helper'
require 'mogilefs'

describe Paranoid do
  context "MogileFS backend" do
    before(:all) do
      #prepare mogilefs
      @mogadm = MogileFS::Admin.new :hosts  => MogileImageStore.backend['hosts']
      unless @mogadm.get_domains[MogileImageStore.backend['domain']]
        @mogadm.create_domain MogileImageStore.backend['domain']
        @mogadm.create_class  MogileImageStore.backend['domain'], MogileImageStore.backend['class'], 2 rescue nil
      end
    end

    before do
      @mg = MogileFS::MogileFS.new({ :domain => MogileImageStore.backend['domain'], :hosts  => MogileImageStore.backend['hosts'] })
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

      it "should increase refcount when saving the same image" do
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 1
        @paranoid.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.jpg"
        lambda{ @paranoid.save }.should_not raise_error
        @paranoid.image.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
        @mg.list_keys('').shift.should == ['bcadded5ee18bfa7c99834f307332b02.jpg']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 2
      end

      it "should accept another image using set_image_data" do
        @paranoid.set_image_data :image, File.open("#{File.dirname(__FILE__)}/../sample.png").read
        lambda{ @paranoid.save }.should_not raise_error
        @paranoid.image.should == '60de57a8f5cd0a10b296b1f553cb41a9.png'
        @mg.list_keys('').shift.sort.should == ['60de57a8f5cd0a10b296b1f553cb41a9.png', 'bcadded5ee18bfa7c99834f307332b02.jpg']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 2
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').refcount.should == 1
      end
    end

    context "overwriting" do
      it "should delete old image when overwritten" do
        @paranoid = Paranoid.find_by_image('60de57a8f5cd0a10b296b1f553cb41a9.png')
        @paranoid.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.gif"
        lambda{ @paranoid.save }.should_not raise_error
        @paranoid.image.should == '5d1e43dfd47173ae1420f061111e0776.gif'
        @mg.list_keys('').shift.sort.should ==
          ['5d1e43dfd47173ae1420f061111e0776.gif',
           'bcadded5ee18bfa7c99834f307332b02.jpg']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 2
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').should be_nil
        MogileImage.find_by_name('5d1e43dfd47173ae1420f061111e0776').refcount.should == 1
      end
    end

    context "saving without uploading image" do
      it "should preserve image name" do
        @paranoid = Paranoid.find_by_image('5d1e43dfd47173ae1420f061111e0776.gif')
        new_name = @paranoid.name + ' new'
        @paranoid.name = new_name
        lambda{ @paranoid.save }.should_not raise_error
        @paranoid.name.should == new_name
        @paranoid.image.should == '5d1e43dfd47173ae1420f061111e0776.gif'
        @mg.list_keys('').shift.sort.should ==
          ['5d1e43dfd47173ae1420f061111e0776.gif',
           'bcadded5ee18bfa7c99834f307332b02.jpg']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 2
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').should be_nil
        MogileImage.find_by_name('5d1e43dfd47173ae1420f061111e0776').refcount.should == 1
      end
    end

    context "deletion" do
      it "should affect nothing on soft removal" do
        @paranoid = Paranoid.find_by_image('bcadded5ee18bfa7c99834f307332b02.jpg')
        lambda{ @paranoid.destroy }.should_not raise_error
        @mg.list_keys('').shift.sort.should ==
          ['5d1e43dfd47173ae1420f061111e0776.gif',
           'bcadded5ee18bfa7c99834f307332b02.jpg']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 2
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').should be_nil
        MogileImage.find_by_name('5d1e43dfd47173ae1420f061111e0776').refcount.should == 1
      end

      it "should decrease refcount when deleting duplicated image" do
        @paranoid = Paranoid.unscoped.find_by_image('bcadded5ee18bfa7c99834f307332b02.jpg')
        lambda{ @paranoid.destroy }.should_not raise_error
        @mg.list_keys('').shift.sort.should ==
          ['5d1e43dfd47173ae1420f061111e0776.gif',
           'bcadded5ee18bfa7c99834f307332b02.jpg']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 1
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').should be_nil
        MogileImage.find_by_name('5d1e43dfd47173ae1420f061111e0776').refcount.should == 1
      end

      it "should delete image data when deleting image" do
        @paranoid = Paranoid.find_by_image('bcadded5ee18bfa7c99834f307332b02.jpg')
        lambda{ @paranoid.destroy! }.should_not raise_error
        @mg.list_keys('').shift.should == ['5d1e43dfd47173ae1420f061111e0776.gif']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').should be_nil
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').should be_nil
        MogileImage.find_by_name('5d1e43dfd47173ae1420f061111e0776').refcount.should == 1
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
