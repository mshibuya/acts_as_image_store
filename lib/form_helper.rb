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
        options = options.symbolize_keys
        output = ''.html_safe
        deletable = options.delete(:deletable)
        if @object[method].is_a?(String) && !@object[method].empty? && @object.persisted?
          # 画像を表示
          width  = options.delete(:w) || MogileImageStore.options[:field_w]
          height = options.delete(:h) || MogileImageStore.options[:field_h]
          output += image(@object[method], options.merge({:w => width, :h => height}))
          # 画像削除用のリンク表示
          if deletable == nil || deletable
            output += @template.link_to(
              (I18n.translate!('mogile_image_store.form_helper.delete') rescue 'delete'),
              { :controller => @template.controller.controller_name,
                :action => 'image_delete',
                :id => @object,
                :column => method, }
            )
          end
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

