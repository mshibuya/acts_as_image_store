# coding: utf-8

module ActsAsImageStore
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
      # ==== options
      # 以下のオプションがある。
      # =====:confirm
      # trueにするとvalidationの時点で画像を仮保存するようになる。
      # 確認画面を挟む場合に使用。
      # =====:keep_exif
      # trueにするとこのモデルに保存される画像はexif情報を残すようになる。
      # （デフォルトでは消去）
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
        include ActsAsImageStore::ActiveRecord::InstanceMethods
        include ActsAsImageStore::ValidatesImageAttribute

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
          if image_options[:confirm] && self[c].is_a?(String) &&
             !self[c].empty? && self.send(c.to_s + '_changed?')
            # 確認経由でセットされたキーがまだ存在するかどうかチェック
            if !StoredImage.key_exist?(self[c])
              errors[c] << I18n.translate('acts_as_image_store.errors.messages.cache_expired')
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
            next unless self.send(c.to_s + '_changed?')
            prev_image = self.send(c.to_s+'_was')
            if prev_image.is_a?(String) && !prev_image.empty?
              ::StoredImage.destroy_image(prev_image)
            end
            ::StoredImage.commit_image(self[c])
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
              ::StoredImage.destroy_image(prev_image)
            end
            self[c] = ::StoredImage.save_image(@image_attributes[c])
          end
        end
      end
      #
      # after_destroyにフック。
      #
      def destroy_images
        image_columns.each do |c|
          ::StoredImage.destroy_image(self[c]) if self[c] && destroyed?
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
        if file.size > ::ActsAsImageStore::options[:maxsize]
          errors[column] << (
            I18n.translate('acts_as_image_store.errors.messages.size_smaller')
            % [::ActsAsImageStore::options[:maxsize]/1024]
          )
        end

        begin
          img_attr = StoredImage.parse_image(file.read,
                                             :keep_exif => self.image_options[:keep_exif])
        rescue ::ActsAsImageStore::InvalidImage
          # 画像ではない場合
          errors[column] << I18n.translate('acts_as_image_store.errors.messages.must_be_image')
          return
        end

        unless ::ActsAsImageStore::IMAGE_FORMATS.include?(img_attr[:type])
          # 対応フォーマットではない場合
          errors[column] << I18n.translate('acts_as_image_store.errors.messages.must_be_valid_type')
          return
        end

        # メタデータを設定
        @image_attributes[column] = img_attr

        # 確認ありの時はこの時点で仮保存
        if image_options[:confirm]
          self[column] = ::StoredImage.save_image(@image_attributes[column], :temporary => true)
        end
      end
    end
  end
end

