# coding: utf-8

##
# == 概要
# 画像タグ作成用ヘルパー
#
module ActionView::Helpers::TagHelper
  def image(key, options = {})
    return if !key || key.empty?
    width  = options.delete(:w) || 0
    height = options.delete(:h) || 0
    if width == 0 && height == 0
      size = 'raw'
    else      
      size = (width > 0 ? width.to_s : '') + 'x' + (height > 0 ? height.to_s : '')
    end
    if (format = options.delete(:format)) != nil
      name, ext = key.split('.')
      key = name + '.' + format
    end
    options[:src] = MogileImageStore::Engine.config.mount_at + size + '/' + key
    tag("img", options)
  end
end

