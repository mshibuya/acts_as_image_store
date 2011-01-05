# coding: utf-8
$:.unshift(File.dirname(__FILE__))

require 'digest/sha1'
##
# == 概要
# 添付画像をMogileFSに格納するプラグイン
#
module MogileImageStore
  require 'mogile_image_store/engine' if defined?(Rails)

  def self.backend
    MogileImageStore::Engine.config.mogile_fs[Rails.env]
  end

  def self.options
    MogileImageStore::Engine.config.options
  end

  def self.auth_key(path)
    Digest::SHA1.hexdigest(path + ':' + backend['secret'])
  end

  class ImageNotFound < StandardError; end
  class SizeNotAllowed < StandardError; end
  class ColumnNotFound < StandardError; end

  AUTH_HEADER = 'X-MogileImageStore-Auth'
  AUTH_HEADER_ENV = 'HTTP_X_MOGILEIMAGESTORE_AUTH'
  IMAGE_FORMATS = ['JPEG', 'GIF', 'PNG']
  TYPE_TO_EXT = { :JPEG => 'jpg', :JPG => 'jpg', :GIF => 'gif', :PNG => 'png'}
  EXT_TO_TYPE = { :jpg => 'JPEG', :gif => 'GIF', :png => 'PNG'}

  autoload :ActiveRecord, 'mogile_image_store/active_record'

  module Validators
    autoload :ValidatesImageType, 'mogile_image_store/validators/image_type'
    autoload :ValidatesFileSize,  'mogile_image_store/validators/file_size'
    autoload :ValidatesWidth,     'mogile_image_store/validators/width'
    autoload :ValidatesHeight,    'mogile_image_store/validators/height'
  end

  autoload :ImageDeletable, 'mogile_image_store/image_deletable'
end


ActiveRecord::Base.class_eval { include MogileImageStore::ActiveRecord }
ActionController::Base.class_eval { include MogileImageStore::ImageDeletable }
require 'tag_helper'
require 'form_helper'

Dir[File.join("#{File.dirname(__FILE__)}/../config/locales/*.yml")].each do |locale|
  I18n.load_path.unshift(locale)
end

