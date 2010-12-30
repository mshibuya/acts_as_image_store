# coding: utf-8

##
# == 概要
# FormHelperを拡張する。
# 入力フォームの作成支援用。
#
module ActionView
  module Helpers
    class FormBuilder
      include TagHelper
      def image_field(method, options = {})
        output = ''.html_safe
        if @object[method]
          # 画像を表示
          width  = options.delete(:w) || MogileImageStore.options[:field_w]
          height = options.delete(:h) || MogileImageStore.options[:field_h]
          output += image(@object[method], options.update({:w => width, :h => height}))
          # 画像削除用のリンク表示
          delete_link_enabled = options.delete(:delete_link)
          delete_link_enabled = true if delete_link_enabled.nil?
          output += @template.link_to(
            (I18n.translate!('mogile_image_store.form_helper.delete') rescue 'delete'),
            { :action => 'image_delete',
              :id => @object,
              :column => method, }
          )
          output += tag('br')
          #to prevent src being set
          options.update({:src => nil})
        end
        # 画像アップロード用フィールド表示
        output +=  @template.file_field(@object_name, method, objectify_options(options))
      end
    end
  end
end

