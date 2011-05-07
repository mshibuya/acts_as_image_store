# coding: utf-8

require 'digest/sha1'

##
# == 概要
# 添付画像をMogileFSに格納するプラグイン
#
module ActsAsImageStore
  require 'acts_as_image_store/engine' if defined?(Rails)

  mattr_accessor :backend, :options

  # 設定を読み込む
  def self.configure
    begin
      backend = ActsAsImageStore::Engine.config.backend[Rails.env]
    rescue NoMethodError
      backend = {}
    end

    ActsAsImageStore.backend = HashWithIndifferentAccess.new(backend)
    ActsAsImageStore.options = HashWithIndifferentAccess.
      new((ActsAsImageStore::Engine.config.options rescue {}))
  end

  # 認証キーを計算する
  def self.auth_key(path)
    Digest::SHA1.hexdigest(path + ':' + backend['secret'])
  end

  class ImageNotFound      < StandardError; end
  class SizeNotAllowed     < StandardError; end
  class ColumnNotFound     < StandardError; end
  class InvalidImage       < StandardError; end
  class UnsupportedAdapter < StandardError; end

  # 認証キーがセットされるHTTPリクエストヘッダ
  AUTH_HEADER = 'X-ActsAsImageStore-Auth'
  # 認証キーがセットされるHTTPリクエストヘッダに対応する環境変数名
  AUTH_HEADER_ENV = 'HTTP_X_MOGILEIMAGESTORE_AUTH'
  # 対応画像フォーマット(RMagick準拠の文字列)
  IMAGE_FORMATS = ['JPEG', 'GIF', 'PNG']
  # 画像フォーマットを拡張子に変換するハッシュ
  TYPE_TO_EXT = { :JPEG => 'jpg', :JPG => 'jpg', :GIF => 'gif', :PNG => 'png'}
  # 拡張子を画像フォーマットに変換するハッシュ
  EXT_TO_TYPE = { :jpg => 'JPEG', :gif => 'GIF', :png => 'PNG'}

  autoload :ActiveRecord, 'acts_as_image_store/active_record'
  autoload :ValidatesImageAttribute,    'acts_as_image_store/validates_image_attribute'
  autoload :ImageDeletable, 'acts_as_image_store/image_deletable'
  autoload :UrlHelper, 'acts_as_image_store/url_helper'
  autoload :TagHelper, 'acts_as_image_store/tag_helper'
  autoload :FormBuilder, 'acts_as_image_store/form_helper'
  module StorageAdapters
    autoload :Abstract, 'acts_as_image_store/storage_adapters/abstract'
  end
  module CacheAdapters
    autoload :Abstract, 'acts_as_image_store/cache_adapters/abstract'
  end

end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.class_eval { include ActsAsImageStore::ActiveRecord }
end
ActiveSupport.on_load(:action_controller) do
  ActionController::Base.class_eval { include ActsAsImageStore::ImageDeletable }
end
ActiveSupport.on_load(:action_view) do
  ActionView::Base.send(:include, ActsAsImageStore::TagHelper)
  ActionView::Helpers::FormBuilder.send(:include, ActsAsImageStore::FormBuilder)
end
ActiveSupport.on_load(:after_initialize) do
  ActsAsImageStore.configure
end

Dir[File.join("#{File.dirname(__FILE__)}/../config/locales/*.yml")].each do |locale|
  I18n.load_path.unshift(locale)
end

