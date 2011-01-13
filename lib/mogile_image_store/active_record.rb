# coding: utf-8

require 'RMagick'

module MogileImageStore
  ##
  # == 概要
  # ActiveRecord::Baseを拡張するモジュール
  #
  module ActiveRecord # :nodoc:
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
    end
    #
    # ActiveRecord::Baseにextendされるモジュール
    #
    module ClassMethods 
      ##
      # 画像保存用のコールバックを設定する。
      #
      # ==== columns
      # 画像が保存されるカラム名を指定。データ型は :string, :limit=>36を使用。
      # 省略時のカラム名はimageとなる。
      #
      # ==== 例:
      #   has_images
      #   has_images :logo
      #   has_images ['banner1', 'banner2']
      # 
      def has_images(columns=nil)
        cattr_accessor  :image_columns
        attr_accessor  :image_attributes

        self.image_columns  = Array.wrap(columns || 'image').map!{|item| item.to_sym }

        class_eval <<-EOV
        include MogileImageStore::ActiveRecord::InstanceMethods
        include MogileImageStore::ValidatesImageType
        include MogileImageStore::ValidatesFileSize
        include MogileImageStore::ValidatesWidth
        include MogileImageStore::ValidatesHeight

        before_validation :validate_images
        before_save       :save_images
        before_destroy    :destroy_images
        EOV
      end
    end
    #
    # 各モデルにincludeされるモジュール
    #
    module InstanceMethods
      #
      # before_validateにフック。
      #
      def validate_images
        @image_attributes = HashWithIndifferentAccess.new
        image_columns.each do |c|
          set_image_attributes c
        end
        false if errors.size > 0
      end
      #
      # before_saveにフック。
      #
      def save_images
        @image_attributes ||= HashWithIndifferentAccess.new
        image_columns.each do |c|
          next if !self[c]
          set_image_attributes(c) unless @image_attributes[c]
          if !@image_attributes[c]
            # バリデーションなしで画像ではないファイルが指定された場合はクリアしておく
            self[c] = nil if self[c].is_a? ActionDispatch::Http::UploadedFile
            next
          end
          prev_image = self.send(c.to_s+'_was')
          if prev_image.is_a?(String) && !prev_image.empty?
            ::MogileImage.destroy_image(prev_image)
          end
          self[c] = ::MogileImage.save_image(@image_attributes[c])
        end
      end
      #
      # before_destroyにフック。
      #
      def destroy_images
        image_columns.each do |c|
          ::MogileImage.destroy_image(self[c]) if self[c]
        end
      end

      ##
      # 画像ファイルをセットするためのメソッド。
      # formからのアップロード時以外に画像を登録する際などに使用。
      #
      def set_image_file(column, path)
        self[column] = ActionDispatch::Http::UploadedFile.new({
          :tempfile => File.open(path)
        })
      end

      protected

      def set_image_attributes(column)
        file = self[column]
        return unless file.is_a?(ActionDispatch::Http::UploadedFile)

        # ファイルサイズの判定
        if file.size > ::MogileImageStore::options[:maxsize]
          errors[column] << (
            I18n.translate('mogile_image_store.errors.messages.size_smaller')
            % [::MogileImageStore::options[:maxsize]/1024]
          )
        end

        content = file.read
        begin
          img = ::Magick::Image.from_blob(content).shift
        rescue
          # 画像ではない場合
          errors[column] << I18n.translate('mogile_image_store.errors.messages.must_be_image')
          return
        end

        unless ::MogileImageStore::IMAGE_FORMATS.include?(img.format)
          # 対応フォーマットではない場合
          errors[column] << I18n.translate('mogile_image_store.errors.messages.must_be_valid_type')
          return
        end

        # メタデータを設定
        @image_attributes[column] = HashWithIndifferentAccess.new({
          'content' => content,
          'size' => file.size,
          'type' => img.format,
          'width' => img.columns,
          'height' => img.rows,
        })
      end
    end
  end
end

