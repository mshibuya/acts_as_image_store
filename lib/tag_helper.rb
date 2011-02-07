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
      def stored_image(key, options = {})
        options = options.symbolize_keys
        return unless url = image_url(key, options)
        %w[w h method size format].each{|i| options.delete(i.to_sym)}
        options[:src] = url
        tag("img", options)
      end

      alias :image :stored_image
    end
  end
end

