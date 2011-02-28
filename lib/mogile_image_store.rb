# coding: utf-8

require 'digest/sha1'

##
# == 概要
# 添付画像をMogileFSに格納するプラグイン
#
module MogileImageStore
  require 'mogile_image_store/engine' if defined?(Rails)

  mattr_accessor :backend, :options

  # 設定を読み込む
  def self.configure
    begin
      backend = MogileImageStore::Engine.config.mogile_fs[Rails.env]
    rescue NoMethodError
      backend = {}
    end
    if backend['mount_at']
      backend['mount_at'] += '/' if backend['mount_at'][-1] != '/'
    end
    if backend['base_url']
      backend['base_url'] += '/' if backend['base_url'][-1] != '/'
    else
      backend['base_url'] = '/image/'
    end

    MogileImageStore.backend = HashWithIndifferentAccess.new(backend)
    MogileImageStore.options = HashWithIndifferentAccess.
      new((MogileImageStore::Engine.config.options rescue {}))
  end

  # 認証キーを計算する
  def self.auth_key(path)
    Digest::SHA1.hexdigest(path + ':' + backend['secret'])
  end

  class ImageNotFound  < StandardError; end
  class SizeNotAllowed < StandardError; end
  class ColumnNotFound < StandardError; end
  class InvalidImage   < StandardError; end

  # Reproxy cache clear時にホスト名を指定するための拡張ヘッダ
  HOST_HEADER = 'X-Reproxy-Host'
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
  autoload :UrlHelper, 'mogile_image_store/url_helper'
  autoload :TagHelper, 'mogile_image_store/tag_helper'
  autoload :FormBuilder, 'mogile_image_store/form_helper'

end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.class_eval { include MogileImageStore::ActiveRecord }
end
ActiveSupport.on_load(:action_controller) do
  ActionController::Base.class_eval { include MogileImageStore::ImageDeletable }
end
ActiveSupport.on_load(:action_view) do
  ActionView::Base.send(:include, MogileImageStore::TagHelper)
  ActionView::Helpers::FormBuilder.send(:include, MogileImageStore::FormBuilder)
end
ActiveSupport.on_load(:after_initialize) do
  MogileImageStore.configure
end

Dir[File.join("#{File.dirname(__FILE__)}/../config/locales/*.yml")].each do |locale|
  I18n.load_path.unshift(locale)
end

