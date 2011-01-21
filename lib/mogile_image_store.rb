# coding: utf-8
$:.unshift(File.dirname(__FILE__))

require 'digest/sha1'

##
# == 概要
# 添付画像をMogileFSに格納するプラグイン
#
module MogileImageStore
  require 'mogile_image_store/engine' if defined?(Rails)

  # Rails.envに合わせたMogileFSバックエンド情報を返す
  def self.backend
    MogileImageStore::Engine.config.mogile_fs[Rails.env]
  end

  # config/initializers/mogile_image_store.rbで指定されたオプションを返す
  def self.options
    MogileImageStore::Engine.config.options rescue {}
  end

  # 認証キーを計算する
  def self.auth_key(path)
    Digest::SHA1.hexdigest(path + ':' + backend['secret'])
  end

  class ImageNotFound < StandardError; end
  class SizeNotAllowed < StandardError; end
  class ColumnNotFound < StandardError; end

  # 認証キーがセットされるHTTPリクエストヘッダ
  AUTH_HEADER = 'X-MogileImageStore-Auth'
  # 認証キーがセットされるHTTPリクエストヘッダに対応する環境変数名
  AUTH_HEADER_ENV = 'HTTP_X_MOGILEIMAGESTORE_AUTH'
  # 対応画像フォーマット(RMagick準拠の文字列)
  IMAGE_FORMATS = ['JPEG', 'GIF', 'PNG']
  # 画像フォーマットを拡張子に変換するハッシュ
  TYPE_TO_EXT = { :JPEG => 'jpg', :JPG => 'jpg', :GIF => 'gif', :PNG => 'png'}
  # 拡張子を画像フォーマットに変換するハッシュ
  EXT_TO_TYPE = { :jpg => 'JPEG', :gif => 'GIF', :png => 'PNG'}

  autoload :ActiveRecord, 'mogile_image_store/active_record'
  autoload :ValidatesImageAttribute,    'mogile_image_store/validates_image_attribute'
  autoload :ImageDeletable, 'mogile_image_store/image_deletable'
end
## :nodoc:
# loading action_controller/deprecated to prevent error with jpmobile
#ActionController::Routing

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.class_eval { include MogileImageStore::ActiveRecord }
end
ActiveSupport.on_load(:action_controller) do
  ActionController::Base.class_eval { include MogileImageStore::ImageDeletable }
end
require 'tag_helper'
require 'form_helper'

Dir[File.join("#{File.dirname(__FILE__)}/../config/locales/*.yml")].each do |locale|
  I18n.load_path.unshift(locale)
end

