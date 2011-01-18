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
      def has_images(columns=nil, options={})
        cattr_accessor  :image_columns, :image_options
        attr_accessor  :image_attributes

        self.image_columns = Array.wrap(columns || 'image').map!{|item| item.to_sym }
        self.image_options = options.symbolize_keys

        class_eval <<-EOV
        include MogileImageStore::ActiveRecord::InstanceMethods
        include MogileImageStore::ValidatesImageAttribute

        before_validation :validate_images
        before_save       :save_images
        after_destroy     :destroy_images
        EOV
      end
      alias :has_image :has_images
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
          if image_options[:confirm] && self[c].is_a?(String) && self.send(c.to_s + '_changed?')
            # 確認経由でセットされたキーがまだ存在するかどうかチェック
            if !MogileImage.key_exist?(self[c])
              errors[c] << I18n.translate('mogile_image_store.errors.messages.confirm_expired')
              self[c] = nil
            end
          else
            set_image_attributes c
          end
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
          if image_options[:confirm]
            # 確認あり経由：すでに画像は保存済み
            prev_image = self.send(c.to_s+'_was')
            if prev_image.is_a?(String) && !prev_image.empty?
              ::MogileImage.destroy_image(prev_image)
            end
            ::MogileImage.commit_image(self[c])
          else
            # 通常時
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
      end
      #
      # after_destroyにフック。
      #
      def destroy_images
        image_columns.each do |c|
          ::MogileImage.destroy_image(self[c]) if self[c] && destroyed?
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

      ##
      # 画像データをファイルを経由せず直接セットするためのメソッド。
      #
      def set_image_data(column, data)
        self[column] = ActionDispatch::Http::UploadedFile.new({
          :tempfile => StringIO.new(data)
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
        # 確認ありの時はこの時点で仮保存
        if image_options[:confirm]
          self[column] = ::MogileImage.save_image(@image_attributes[column], :temporary => true)
        end
      end
    end
  end
end

