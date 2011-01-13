# coding: utf-8

module ActionView # :nodoc:
  module Helpers # :nodoc:
    ##
    # == 概要
    # 画像タグ作成用ヘルパー
    #
    module TagHelper
      ##
      # ===画像タグ表示メソッド
      #
      # 画像アップロード用のinputタグを生成します。
      #
      # ==== _key_
      # 画像のキーを指定します。
      #
      # ==== _options_
      # w, h, method, size, format
      #
      # ====返り値
      # 生成したタグを返します。
      #
      def image(key, options = {})
        return if !key || !key.respond_to?(:empty?) || key.empty?
        options = options.symbolize_keys
        width  = options.delete(:w) || 0
        height = options.delete(:h) || 0
        method = options.delete(:method) || ''
        unless size = options.delete(:size)
          if width == 0 && height == 0
            size = 'raw'
          else
            size = "#{width.to_s}x#{height.to_s}#{method.to_s}" 
          end
        end
        if (format = options.delete(:format)) != nil
          name, ext = key.split('.')
          key = name + '.' + format.to_s
        end
        path = MogileImageStore::Engine.config.mount_at + size + '/' + key
        if MogileImageStore.backend['imghost']
          options[:src] = 'http://' + MogileImageStore.backend['imghost'] + path
        else
          options[:src] = path
        end
        tag("img", options)
      end
    end
  end
end

