# coding: utf-8
require 'mogilefs'
require 'digest/md5'
require 'net/http'

class MogileImage < ActiveRecord::Base
  CONTENT_TYPES = HashWithIndifferentAccess.new ({
    :jpg => 'image/jpeg',
    :gif => 'image/gif',
    :png => 'image/png',
  })

  class << MogileImage
    ##
    # 同一ハッシュのレコードが存在するかどうか調べ、
    # なければレコードを作成すると同時にMogileFSに保存する。
    # あれば参照カウントを1増やす。
    #
    def save_image(image_attrs, options = {})
      temporary = options.delete(:temporary) || false
      content = image_attrs['content']
      name = Digest::MD5.hexdigest(content)
      self.transaction do
        record = find_or_initialize_by_name name
        unless record.persisted?
          image_attrs.map{ |k,v| record[k] = v if %w[size width height].include? k }
          record.image_type = ::MogileImageStore::TYPE_TO_EXT[image_attrs['type'].to_sym.upcase]
          if temporary
            record.refcount = 0
            record.keep_till = Time.now + (MogileImageStore.options[:upload_cache] || 3600)
          else
            record.refcount = 1
          end
          record.save!
          filename = name+'.'+record['image_type']
          mg = mogilefs_connect
          mg.store_content filename, MogileImageStore.backend['class'], content
          filename
        else
          if temporary
            record.keep_till = Time.now + (MogileImageStore.options[:upload_cache] || 3600)
          else
            record.refcount += 1
          end
          record.save
          filename = name+'.'+record['image_type']
        end
      end
    end

    ##
    # 確認画面経由で一時保存されているデータを確定
    #
    def commit_image(key)
      return unless key.is_a?(String) && !key.empty?
      name, ext = key.split('.')
      self.transaction do
        record = find_by_name name
        raise MogileImageStore::ImageNotFound unless record
        record.refcount += 1
        if record.keep_till && record.keep_till < Time.now
          record.keep_till = nil
        end
        record.save
      end
    end

    ##
    # 指定されたハッシュ値を持つレコードを削除し、
    # 同時にMogileFSからリサイズ分も含めその画像を削除する。
    #
    def destroy_image(key)
      return unless key.is_a?(String) && !key.empty?
      name, ext = key.split('.')
      self.transaction do
        record = find_by_name name
        raise MogileImageStore::ImageNotFound unless record
        if record.refcount > 1
          record.refcount -= 1
          record.save
        else
          if record.keep_till && record.keep_till > Time.now
            record.refcount = 0
            record.save
          else
            record.delete
            purge_image_data(name)
          end
        end
      end
      cleanup_temporary_image
    end
    ##
    # 指定されたキーを持つ画像のURLをMogileFSより取得して返す。
    # X-REPROXY-FORヘッダでの出力に使う。
    #
    def fetch_urls(name, format, size='raw')
      [self::CONTENT_TYPES[format.to_sym],
        retrieve_image(name, format, size) {|mg,key| mg.get_paths key }]
    end

    ##
    # 指定されたキーを持つ画像のデータを取得して返す。
    #
    def fetch_data(name, format, size='raw')
      [self::CONTENT_TYPES[format.to_sym],
        retrieve_image(name, format, size) {|mg,key| mg.get_file_data key }]
    end

    ##
    # 保存期限を過ぎた一時データを消去する
    #
    def cleanup_temporary_image
      self.transaction do
        self.where('keep_till < ?', Time.now).all.each do |record|
          if record.refcount > 0
            record.keep_till = nil
            record.save
          else
            record.delete
            purge_image_data(record.name)
          end
        end
      end
    end

    def key_exist?(key)
      name, ext = key.split('.')
      !!self.find_by_name(name)
    end

    protected

    ##
    # パラメータからMogileFSのキーを生成し、引数で受け取ったブロックに渡す
    #
    def retrieve_image(name, format, size, &block)
      record = find_by_name(name)
      raise MogileImageStore::ImageNotFound unless record

      # check whether size is allowd
      raise MogileImageStore::SizeNotAllowed unless size_allowed?(size)

      if resize_needed? record, format, size
        key = "#{name}.#{format}/#{size}"
      else
        #needs no resizing
        key = "#{name}.#{format}"
      end
      mg = mogilefs_connect
      begin
        return block.call(mg, key)
      rescue MogileFS::Backend::UnknownKeyError
        # 画像がまだ生成されていないので生成する
        begin
          img = ::Magick::Image.from_blob(mg.get_file_data("#{name}.#{record.image_type}")).shift
        rescue MogileFS::Backend::UnknownKeyError
          raise MogileImageStore::ImageNotFound
        end
        mg.store_content key, MogileImageStore.backend['class'], resize_image(img, format, size).to_blob
      end
      return block.call(mg, key)
    end

    ##
    # 画像をリサイズ・変換
    #
    def resize_image(img, format, size)
      w, h, method, n = size.scan(/(\d+)x(\d+)([a-z]*)(\d*)/).shift
      w, h, n = [w, h, n].map {|i| i.to_i if i }
      case method
      when 'fill'
        n ||= 0
        img.resize_to_fit! w-n*2, h-n*2
        background = ::Magick::Image.new(w, h) { self.background_color = "black" }
        img = background.composite(img, Magick::CenterGravity, Magick::OverCompositeOp)
      else
        if size != 'raw' && (img.columns > w || img.rows > h)
          img.resize_to_fit! w, h
        end
      end
      new_format = ::MogileImageStore::EXT_TO_TYPE[format.to_sym]
      img.format = new_format if img.format != new_format
      img
    end
    ##
    # MogileFSキーからURLを復元する
    #
    def parse_key(key)
      name, format, size = key.scan(/([0-9a-f]{32})\.(jpg|gif|png)(?:\/(\d+x\d+[a-z]*\d*))?/).shift
      size ||= 'raw'
      MogileImageStore::Engine.config.mount_at + size + '/' + name + '.' + format if name && format
    end

    ##
    # 画像リサイズが必要かどうか判定
    #
    def resize_needed?(record, format, size)
      return false if size == 'raw'

      # 加工が指定されているなら必要
      w, h, method = size.scan(/(\d+)x(\d+)([a-z]*\d*)/).shift
      return true if method && !method.empty?

      # オリジナルの画像サイズと比較
      w, h =  [w, h].map{|i| i.to_i}
      if w > record.width && h > record.height
        false
      else
        true
      end
    end

    ##
    # 画像サイズが許可されているかどうか判定
    #
    def size_allowed?(size)
      MogileImageStore.options[:allowed_sizes].each do |item|
        if item.is_a? Regexp
          return true if size.match(item)
        else
          return true if size == item
        end
      end
      return false
    end

    ##
    # MogileFS上の指定されたハッシュ値を持つ画像データを消去
    #
    def purge_image_data(name)
      mg = mogilefs_connect
      urls = []
      mg.each_key(name) do |k|
        mg.delete k
        url = parse_key k
        urls.push(url) if url
      end
      if urls.size > 0 && MogileImageStore.backend['reproxy']
        host, port = MogileImageStore.backend['imghost'].split(':')
        # Request asynchronously
        t = Thread.new(urls.join(' ')) do |body|
          Net::HTTP.start(host, port || 80) do |http|
            http.post(MogileImageStore::Engine.config.mount_at + 'flush', body, {MogileImageStore::AUTH_HEADER => MogileImageStore.auth_key(body)})
          end
        end
      end
    end

    ##
    # :nodoc:
    def mogilefs_connect
      begin
        return @@mogilefs
      rescue
        @@mogilefs = MogileFS::MogileFS.new({
          :domain => MogileImageStore.backend['domain'],
          :hosts  => MogileImageStore.backend['hosts'],
        })
      end
    end
  end
end
