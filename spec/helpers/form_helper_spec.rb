# coding: utf-8
require 'spec_helper'

describe ActionView::Helpers::FormHelper do
  context "MogileFS backend" do
    before(:all) do
      #prepare mogilefs
      @mogadm = MogileFS::Admin.new :hosts  => MogileImageStore.backend['hosts']
      unless @mogadm.get_domains[MogileImageStore.backend['domain']]
        @mogadm.create_domain MogileImageStore.backend['domain']
        @mogadm.create_class  MogileImageStore.backend['domain'], MogileImageStore.backend['class'], 2 rescue nil
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

    before do
      @image_test = Factory.build(:image_test)
    end

    it "should show file field" do
      form_for(@image_test) do |f|
        f.image_field(:image).should == '<input id="image_test_image" name="image_test[image]" type="file" />'
      end
    end

    describe "when image exists" do
      before do
        @image_test.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.png"
        @image_test.save
      end

      it "should show file field" do
        @image_test.image = ''
        form_for(@image_test) do |f|
          f.image_field(:image).should == '<input id="image_test_image" name="image_test[image]" type="file" />'
        end
      end

      it "should show file field with image and delete link" do
        form_for(@image_test) do |f|
          f.image_field(:image).should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/80x80/60de57a8f5cd0a10b296b1f553cb41a9.png" /><a href="/test/'+@image_test.id.to_s+'/image_delete/image" data-confirm="Are you sure?">delete</a><br /><input id="image_test_image" name="image_test[image]" type="file" />'
        end
      end

      it "should show file field with image and delete link without confirm" do
        form_for(@image_test) do |f|
          f.image_field(:image, :link_options => {:confirm => false}).should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/80x80/60de57a8f5cd0a10b296b1f553cb41a9.png" /><a href="/test/'+@image_test.id.to_s+'/image_delete/image">delete</a><br /><input id="image_test_image" name="image_test[image]" type="file" />'
        end
      end

      it "should show file field with image without delete link" do
        form_for(@image_test) do |f|
          f.image_field(:image, :deletable => false).should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/80x80/60de57a8f5cd0a10b296b1f553cb41a9.png" /><br /><input id="image_test_image" name="image_test[image]" type="file" />'
        end
      end

      it "should show file field with image and delete link with width and height" do
        form_for(@image_test) do |f|
          f.image_field(:image, :w => 100, :h => 100).should ==
            '<img src="http://'+MogileImageStore.backend['imghost']+'/image/100x100/60de57a8f5cd0a10b296b1f553cb41a9.png" /><a href="/test/' +
            @image_test.id.to_s +
            '/image_delete/image" data-confirm="Are you sure?">delete</a><br /><input id="image_test_image" name="image_test[image]" type="file" />'
        end
      end

      it "should show file field with image and delete link with options" do
        form_for(@image_test) do |f|
          f.image_field(:image, :w => 100, :h => 100,
                        :image_options => {:alt=>'alt text'},
                        :link_options => {:rel=>'external'},
                        :input_options => {:class=>'upload'}).should ==
            '<img alt="alt text" src="http://'+MogileImageStore.backend['imghost']+'/image/100x100/60de57a8f5cd0a10b296b1f553cb41a9.png" /><a href="/test/' +
            @image_test.id.to_s +
            '/image_delete/image" data-confirm="Are you sure?" rel="external">delete</a><br /><input class="upload" id="image_test_image" name="image_test[image]" type="file" />'
        end
      end
    end

    context "confirm" do
      before do
        @confirm = Factory.build(:confirm)
        @confirm.set_image_file :image, "#{File.dirname(__FILE__)}/../sample.png"
        @confirm.valid?
      end

      it "should show hidden field when confirm" do
        form_for(@confirm) do |f|
          f.image_field(:image, :confirm => true).should == '<img src="http://'+MogileImageStore.backend['imghost']+'/image/raw/60de57a8f5cd0a10b296b1f553cb41a9.png" /><br /><input id="confirm_image" name="confirm[image]" type="hidden" value="60de57a8f5cd0a10b296b1f553cb41a9.png" />'
        end
      end
    end
  end
end
