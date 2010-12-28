# coding: utf-8
$:.unshift(File.dirname(__FILE__))

require 'RMagick'

##
# == 概要
# 添付画像をMogileFSに格納するプラグイン
#
module MogileImageStore
  require 'mogile_image_store/engine' if defined?(Rails)

  def self.included(base)
    base.extend(ClassMethods)
  end

  def self.backend
    MogileImageStore::Engine.config.mogile_fs[Rails.env.to_sym]
  end

  class ImageNotFound < StandardError; end
  class SizeNotAllowed < StandardError; end

  IMAGE_FORMATS = ['JPEG', 'GIF', 'PNG']
  TYPE_TO_EXT = { :JPEG => 'jpg', :JPG => 'jpg', :GIF => 'gif', :PNG => 'png'}
  EXT_TO_TYPE = { :jpg => 'JPEG', :gif => 'GIF', :png => 'PNG'}

  #
  # ActiveRecord::Baseにincludeするモジュール
  #
  module ClassMethods
    def has_images(columns=nil, options = {})
      cattr_accessor  :image_columns, :version_message, :deleted_message
      attr_accessor  :image_attributes

      self.image_columns  = Array.wrap(columns || 'image').map!{|item| item.to_sym }

      class_eval <<-EOV
        include MogileImageStore::InstanceMethods
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
      image_columns.each do |c|
        set_image_attributes c
      end
    end
    #
    # before_saveにフック。
    #
    def save_images
      image_columns.each do |c|
        set_image_attributes(c) if self[c] && !(@image_attributes[c] rescue nil)
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

      @image_attributes ||= HashWithIndifferentAccess.new

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

  module Validators
    autoload :ValidatesImageType, 'mogile_image_store/validators/image_type'
    autoload :ValidatesFileSize,  'mogile_image_store/validators/file_size'
    autoload :ValidatesWidth,     'mogile_image_store/validators/width'
    autoload :ValidatesHeight,    'mogile_image_store/validators/height'
  end
end


ActiveRecord::Base.class_eval { include MogileImageStore }

Dir[File.join("#{File.dirname(__FILE__)}/../config/locales/*.yml")].each do |locale|
  I18n.load_path.unshift(locale)
end

