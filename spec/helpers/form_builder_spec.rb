# coding: utf-8
require 'spec_helper'

describe ActsAsImageStore::FormBuilder, :backend => true do
  it "should show file field" do
    @image_test = Factory.build(:image_test)
    form_for(@image_test) do |f|
      f.image_field(:image).should == '<input id="image_test_image" name="image_test[image]" type="file" />'
    end
  end

  describe "when image exists" do
    before do
      @image_test = Factory.build(:image_test)
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
        f.image_field(:image).should == '<a href="'+ActsAsImageStore.backend['base_url']+'raw/60de57a8f5cd0a10b296b1f553cb41a9.png" target="_blank"><img src="'+ActsAsImageStore.backend['base_url']+'80x80/60de57a8f5cd0a10b296b1f553cb41a9.png" /></a><a href="/test/'+@image_test.id.to_s+'/image_delete/image" data-confirm="Are you sure?">delete</a><br /><input id="image_test_image" name="image_test[image]" type="file" />'
      end
    end

    it "should show file field with image and delete link without confirm" do
      form_for(@image_test) do |f|
        f.image_field(:image, :link_options => {:confirm => false}).should == '<a href="'+ActsAsImageStore.backend['base_url']+'raw/60de57a8f5cd0a10b296b1f553cb41a9.png" target="_blank"><img src="'+ActsAsImageStore.backend['base_url']+'80x80/60de57a8f5cd0a10b296b1f553cb41a9.png" /></a><a href="/test/'+@image_test.id.to_s+'/image_delete/image">delete</a><br /><input id="image_test_image" name="image_test[image]" type="file" />'
      end
    end

    it "should show file field with image without delete link" do
      form_for(@image_test) do |f|
        f.image_field(:image, :deletable => false).should == '<a href="'+ActsAsImageStore.backend['base_url']+'raw/60de57a8f5cd0a10b296b1f553cb41a9.png" target="_blank"><img src="'+ActsAsImageStore.backend['base_url']+'80x80/60de57a8f5cd0a10b296b1f553cb41a9.png" /></a><br /><input id="image_test_image" name="image_test[image]" type="file" />'
      end
    end

    it "should show file field with image and delete link with width and height" do
      form_for(@image_test) do |f|
        f.image_field(:image, :w => 100, :h => 100).should ==
          '<a href="'+ActsAsImageStore.backend['base_url']+'raw/60de57a8f5cd0a10b296b1f553cb41a9.png" target="_blank"><img src="'+ActsAsImageStore.backend['base_url']+'100x100/60de57a8f5cd0a10b296b1f553cb41a9.png" /></a><a href="/test/' +
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
                      '<a href="'+ActsAsImageStore.backend['base_url']+'raw/60de57a8f5cd0a10b296b1f553cb41a9.png" target="_blank"><img alt="alt text" src="'+ActsAsImageStore.backend['base_url']+'100x100/60de57a8f5cd0a10b296b1f553cb41a9.png" /></a><a href="/test/' +
                      @image_test.id.to_s +
                      '/image_delete/image" data-confirm="Are you sure?" rel="external">delete</a><br /><input class="upload" id="image_test_image" name="image_test[image]" type="file" />'
      end
    end

    it "should show file field for rails_admin" do
      form_for(@image_test) do |f|
        f.rails_admin_image_field(:image).should ==
                      "<a href=\"http://image.example.com/images/raw/60de57a8f5cd0a10b296b1f553cb41a9.png\" target=\"_blank\"><img src=\"http://image.example.com/images/80x80/60de57a8f5cd0a10b296b1f553cb41a9.png\" /></a><a href=\"/rails_admin/image_store/#{@image_test.id.to_s}/image_delete/image\" data-confirm=\"Are you sure?\">delete</a><input id=\"image_test_image\" name=\"image_test[image]\" type=\"file\" />"
      end
    end
  end

  context "multiple" do
    before do
      @multiple = Factory.build(:multiple)
      @multiple.add_image_file :photo, "#{File.dirname(__FILE__)}/../sample.png"
      @multiple.save
    end

    it "should show file field for multiple image" do
      form_for(@multiple) do |f|
        f.multiple_image_field(:photo).should ==
                      "            <table class=\"multiple_images\" data-limit=\"\" border=\"0\">\n              <tbody>\n                <tr id=\"multiple_photo_1\">\n                  <th>Photo<input type=\"button\" value=\"削除\" /></th>\n                  <td>\n                  <img src=\"http://image.example.com/images/80x80/60de57a8f5cd0a10b296b1f553cb41a9.png\" />\n                  <input type=\"hidden\" name=\"multiple[uploaded_photos][]\" value=\"60de57a8f5cd0a10b296b1f553cb41a9.png\" />\n                  </td>\n                </tr>\n              </tbody>\n              <tbody style=\"display:none\">\n                <tr>\n                  <th>Photo<input type=\"button\" value=\"削除\" /></th>\n                  <td><input type=\"file\" name=\"multiple[uploaded_photos][]\" /></td>\n                </tr>\n              </tbody>\n            </table>\n            <input class=\"multiple_image_add\" type=\"button\" value=\"追加\" />\n\n"
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
        f.image_field(:image, :confirm => true).should == '<img src="'+ActsAsImageStore.backend['base_url']+'raw/60de57a8f5cd0a10b296b1f553cb41a9.png" /><br /><input id="confirm_image" name="confirm[image]" type="hidden" value="60de57a8f5cd0a10b296b1f553cb41a9.png" />'
      end
    end
  end
end
