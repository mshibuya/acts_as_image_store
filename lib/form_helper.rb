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
          output += image(@object[method], options.update({:w => 80, :h => 80}))
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
        output +=  @template.file_field(@object_name, method, objectify_options(options))
      end
    end
  end
end

