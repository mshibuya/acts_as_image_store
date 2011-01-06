require 'spec_helper'
require 'mogilefs'

describe Multiple do
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
        @multiple = Factory.build(:multiple)
      end

      it "should return hash value when saved" do
        @multiple.set_image_file :banner1, "#{File.dirname(__FILE__)}/../sample.jpg"
        @multiple.set_image_file :banner2, "#{File.dirname(__FILE__)}/../sample.png"
        lambda{ @multiple.save }.should_not raise_error
        @multiple.banner1.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
        @multiple.banner2.should == '60de57a8f5cd0a10b296b1f553cb41a9.png'
        @mg.list_keys('').shift.sort.should == ['60de57a8f5cd0a10b296b1f553cb41a9.png', 'bcadded5ee18bfa7c99834f307332b02.jpg']
      end

      it "should increase refcount when saving the same image" do
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 1
        @multiple.set_image_file :banner2, "#{File.dirname(__FILE__)}/../sample.jpg"
        lambda{ @multiple.save }.should_not raise_error
        @multiple.banner2.should == 'bcadded5ee18bfa7c99834f307332b02.jpg'
        @mg.list_keys('').shift.sort.should == ['60de57a8f5cd0a10b296b1f553cb41a9.png', 'bcadded5ee18bfa7c99834f307332b02.jpg']
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 2
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').refcount.should == 1
      end
    end

    context "deletion" do
      before do
        @multiple = Multiple.first
      end

      it "should decrease refcount when deleting duplicated image" do
        lambda{ @multiple.destroy }.should_not raise_error
        @mg.list_keys('').shift.sort.should ==
          ['bcadded5ee18bfa7c99834f307332b02.jpg',]
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').refcount.should == 1
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').should be_nil
      end

      it "should delete image data when deleting image" do
        lambda{ @multiple.destroy }.should_not raise_error
        @mg.list_keys('').should be_nil
        MogileImage.find_by_name('bcadded5ee18bfa7c99834f307332b02').should be_nil
        MogileImage.find_by_name('60de57a8f5cd0a10b296b1f553cb41a9').should be_nil
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
