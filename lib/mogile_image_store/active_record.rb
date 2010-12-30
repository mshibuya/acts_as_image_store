# coding: utf-8

require 'RMagick'

##
# == 概要
# ActiveRecord::Baseを拡張するモジュール
#
module MogileImageStore
  #
  # ActiveRecord::Baseにincludeするモジュール
  #
  module ActiveRecord
    def self.included(base)
      base.extend(ClassMethods)
    end
    #
    # ActiveRecord::Baseにextendされるモジュール
    #
    module ClassMethods
      def has_images(columns=nil, options = {})
        cattr_accessor  :image_columns
        attr_accessor  :image_attributes

        self.image_columns  = Array.wrap(columns || 'image').map!{|item| item.to_sym }

        class_eval <<-EOV
        include MogileImageStore::ActiveRecord::InstanceMethods
        include MogileImageStore::Validators::ValidatesImageType
        include MogileImageStore::Validators::ValidatesFileSize
        include MogileImageStore::Validators::ValidatesWidth
        include MogileImageStore::Validators::ValidatesHeight

        before_validation :validate_images
        before_save       :save_images
        before_destroy    :destroy_images
      EOV
      end
    end
    #
    # 各モデルにincludeされるモジュール
    #
    module InstanceMethods
      #
      # before_validateにフック。
      #
      def validate_images
        @image_attributes = HashWithIndifferentAccess.new
        image_columns.each do |c|
          set_image_attributes c
        end
      end
      #
      # before_saveにフック。
      #
      def save_images
        @image_attributes ||= HashWithIndifferentAccess.new
        image_columns.each do |c|
          next if !self[c]
          set_image_attributes(c) unless @image_attributes[c]
          next unless @image_attributes[c]
          self[c] = ::MogileImage.save_image(@image_attributes[c])
        end
      end
      #
      # before_destroyにフック。
      #
      def destroy_images
        image_columns.each do |c|
          ::MogileImage.destroy_image(self[c]) if self[c]
        end
      end

      ##
      # 画像ファイルをセットするためのメソッド。
      # formからのアップロード時以外に画像を登録する際などに使用。
      #
      def set_image_file(column, path)
        self[column] = ActionDispatch::Http::UploadedFile.new({
          :tempfile => File.open(path)
        })
      end

      protected

      def set_image_attributes(column)
        file = self[column]
        return unless file.is_a?(ActionDispatch::Http::UploadedFile)

        content = file.read
        img = ::Magick::Image.from_blob(content).shift rescue return
        if  ::MogileImageStore::IMAGE_FORMATS.include?(img.format)
          @image_attributes[column] = HashWithIndifferentAccess.new({
            'content' => content,
            'size' => file.size,
            'type' => img.format,
            'width' => img.columns,
            'height' => img.rows,
          })
        end
      end
    end
  end
end

