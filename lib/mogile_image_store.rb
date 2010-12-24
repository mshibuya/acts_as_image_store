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

      self.image_columns  = columns || ['image']
      #      self.version_message = options[:msg_updated] || I18n.translate('acts_as_optimistic_lock.errors.messages.updated')
      #      self.deleted_message = options[:msg_deleted] || I18n.translate('acts_as_optimistic_lock.errors.messages.deleted')

      class_eval <<-EOV
        include MogileImageStore::InstanceMethods
        include MogileImageStore::Validators::ValidatesImageType
        include MogileImageStore::Validators::ValidatesFileSize
        include MogileImageStore::Validators::ValidatesWidth
        include MogileImageStore::Validators::ValidatesHeight

        before_validation :validate_attachments
        before_save       :save_attachments
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
    def validate_attachments
      image_columns.each do |c|
        set_image_attributes c
      end
    end
    #
    # before_saveにフック。
    #
    def save_attachments
      image_columns.each do |c|
        set_image_attributes(c) if attributes[c] && !@image_attributes[c]
        next unless @image_attributes[c]
        self[c] = ::MogileImage.save_image(@image_attributes[c])
      end
    end

    protected

    def set_image_attributes(column)
      file = attributes[column]
      return unless file.is_a?(ActionDispatch::Http::UploadedFile)

      @image_attributes ||= HashWithIndifferentAccess.new

      content = file.read
      img = ::Magick::Image.from_blob(content).shift
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

