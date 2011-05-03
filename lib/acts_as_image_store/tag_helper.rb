# coding: utf-8

module ActsAsImageStore # :nodoc:
  ##
  # == 概要
  # 画像タグ作成用ヘルパー
  #
  module TagHelper
    extend ActiveSupport::Concern
    include ActsAsImageStore::UrlHelper
    ##
    # ===画像タグ表示メソッド
    #
    # 画像表示用のimgタグを生成します。
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
    def stored_image(key, options = {})
      options = options.symbolize_keys
      options[:default] ||= :default
      return unless url = image_url(key, options)
      %w[w h method size format default].each{|i| options.delete(i.to_sym)}
      options[:src] = url
      tag("img", options)
    end

    alias :image :stored_image

    ##
    # ===画像サムネイル表示メソッド
    #
    # 画像サムネイル用のimgタグを生成します。
    #
    # ==== _key_
    # 画像のキーを指定します。
    #
    # ==== _options_
    # w, h, method, size, format, link
    #
    # ====返り値
    # 生成したタグを返します。
    #
    def thumbnail(key, options = {})
      options = options.symbolize_keys
      is_link = options.key?(:link) ? options.delete(:link) : true
      thumb_tag = stored_image(key,
        { :w => ActsAsImageStore.options[:field_w],
          :h => ActsAsImageStore.options[:field_h], }.merge(options)
      )
      if is_link && key && key.respond_to?(:empty?) && !key.empty?
        %w[w h].each{|i| options[i.to_sym] = 0}
        thumb_tag = link_to(thumb_tag, image_url(key, options), {:target => :_blank})
      end
      thumb_tag
    end
  end
end

