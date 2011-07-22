# coding: utf-8

module ActsAsImageStore # :nodoc:
  ##
  # == 概要
  # FormBuilderを拡張する。
  # 入力フォームの作成支援用。
  #
  module FormBuilder
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper
    include ActsAsImageStore::TagHelper
    ##
    # ===画像フォーム表示メソッド
    #
    # 画像アップロード用のinputタグ、及び画像がすでにセットされている際には
    # サムネイル画像タグと画像削除用リンクのタグを生成します。
    #
    # ==== _method_
    # 画像を格納するカラムを指定します。
    #
    # ==== _options_
    # ===== confirm=false
    # 確認画面でhiddenフィールドを表示させたい時に指定します。
    #
    # ===== w, h
    # 幅、高さを指定します。
    #
    # ===== deletable=true
    # 削除用リンクを表示するかどうかを指定します。
    #
    # ===== image_options={}, link_options={}, input_options={}
    # それぞれimgタグ、削除用リンクタグ、inputタグに渡す個別オプションを指定します。
    #
    # ====返り値
    # 生成したタグを返します。
    #
    def image_field(method, options = {})
      options = options.symbolize_keys
      confirm   = options.delete(:confirm) || false

      image_options = options.delete(:image_options) || {}
      input_options = options.delete(:input_options) || {}
      link_options  = options.delete(:link_options) || {}
      if confirm
        image_options[:w] ||= 0
        image_options[:h] ||= 0
        image_options[:link] = false
        deletable = false
        show_image = @object[method].is_a?(String) && !@object[method].empty?
      else
        image_options[:w] = options[:w] if options[:w]
        image_options[:h] = options[:h] if options[:h]
        deletable = options.delete(:deletable)
        show_image = @object[method].is_a?(String) && !@object[method].empty? && @object.persisted?
      end

      output = ''.html_safe
      if show_image
        without_br = link_options.delete(:without_br)
        link_url  = link_options.delete(:url) || {
          :controller => @template.controller.controller_name,
          :action => 'image_delete',
          :id => @object,
          :column => method,
        }
        # 画像を表示
        output += thumbnail(@object[method], image_options)
        # 画像削除用のリンク表示
        if deletable === nil || deletable
          output += @template.link_to(
            (I18n.translate!('acts_as_image_store.form_helper.delete') rescue 'delete'),
              link_url,
              { :confirm => I18n.translate('acts_as_image_store.notices.confirm') }.merge(link_options),
          )
        end
        output += tag('br') unless without_br
      end
      # 画像アップロード用フィールド表示
      if confirm
        if @object[method]
          output +=  @template.hidden_field(@object_name, method, objectify_options(input_options))
        end
      else
        output +=  @template.file_field(@object_name, method, objectify_options(input_options))
      end
    end
    def rails_admin_image_field(method, options={})
      image_field(method, {
        :link_options => {
          :without_br => true,
          :url => {
            :controller => "rails_admin/image_store",
            :model_name => @template.controller.params['model_name'],
            :action => "image_delete",
            :id => @object,
            :column => method,
          }
        }
      }.merge(options))
    end
  end
end

