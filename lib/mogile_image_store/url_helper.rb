# coding: utf-8

module MogileImageStore # :nodoc:
  ##
  # == 概要
  # 画像URL用ヘルパー
  #
  module UrlHelper
    ##
    # ===画像URL取得メソッド
    #
    # 保存された画像のURLを返します。
    #
    # ==== _key_
    # 画像のキーを指定します。
    #
    # ==== _options_
    # w, h, method, size, format
    #
    # ====返り値
    # 画像のURLを返します。
    #
    def image_url(key, options = {})
      if !key || !key.respond_to?(:empty?) || key.empty?
        if options[:default]
          key = MogileImageStore.options[:alternatives][options[:default]]
        end
        return nil if !key || !key.respond_to?(:empty?) || key.empty?
      end
      key = key.to_s
      options = options.symbolize_keys
      width  = options[:w] || 0
      height = options[:h] || 0
      method = options[:method] || ''
      unless size = options[:size]
        if width == 0 && height == 0
          size = 'raw'
        else
          size = "#{width.to_s}x#{height.to_s}#{method.to_s}" 
        end
      end
      if (format = options[:format]) != nil
        name, ext = key.split('.')
        key = name + '.' + format.to_s
      end
      
      MogileImageStore.backend['base_url'] + size + '/' + key
    end
  end
end

