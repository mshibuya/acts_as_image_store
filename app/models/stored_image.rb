# coding: utf-8
require 'mogilefs'
require 'digest/md5'
require 'net/http'

class StoredImage < ActiveRecord::Base
  extend ActsAsImageStore::UrlHelper

  CONTENT_TYPES = HashWithIndifferentAccess.new ({
    :jpg => 'image/jpeg',
    :gif => 'image/gif',
    :png => 'image/png',
  })

  class << self
    def load_adapter(kind)
      begin
        adapter_name = ActsAsImageStore.backend[:storage][:adapter].downcase
        adapters_module = ::ActsAsImageStore.const_get("#{kind}_adapters".camelcase)
        require File.join(File.dirname(__FILE__), '..', '..',
                          'lib', 'acts_as_image_store',  "#{kind}_adapters", adapter_name)
        klass = adapters_module.const_get(adapter_name.camelcase)
        klass.load(self) unless klass.loaded
        klass.new(ActsAsImageStore.backend[kind])
      rescue LoadError
        raise ActsAsImageStore::UnsupportedAdapter, "`#{adapter_name}` is not a supported #{kind} adapter."
      end
    end

    def storage
      @storage ||= load_adapter(:storage)
    end

    def cache
      @cache ||= load_adapter(:cache)
    end
    ##
    # returns metadatas of image
    #
    def parse_image(data, options={})
      options = options.symbolize_keys
      begin
        imglist = ::Magick::ImageList.new
        imglist.from_blob(data)
      rescue
        raise ::ActsAsImageStore::InvalidImage
      end
      # check if pre-resize is needed
      noresize = true
      noresize = false if ::ActsAsImageStore.options[:maxwidth] &&
          imglist.first.columns > ::ActsAsImageStore.options[:maxwidth].to_i
      noresize = false if ::ActsAsImageStore.options[:maxheight] &&
          imglist.first.columns > ::ActsAsImageStore.options[:maxheight].to_i

      # check if strip is needed
      nostrip = (options[:keep_exif] ||
                  imglist.inject([]){|r,i| r.concat(i.get_exif_by_entry()) } == [])
      if noresize && nostrip
        content = data
      else
        unless noresize
          imglist.each do |i|
            i.resize_to_fit!(ActsAsImageStore.options[:maxwidth],
                             ActsAsImageStore.options[:maxheight])
          end
        end
        unless nostrip
          # strip exif info
          imglist.each{|i| i.strip! }
        end
        content = imglist.to_blob
      end
      img = imglist.first
      HashWithIndifferentAccess.new({
        'content' => content,
        'size' => content.size,
        'type' => img.format,
        'width' => img.columns,
        'height' => img.rows,
      })
    end
    ##
    # send image to storage.
    # if image already exists in storage, then increment refcount.
    #
    def save_image(image_attrs, options = {})
      temporary = options.delete(:temporary) || false
      content = image_attrs['content']
      name = Digest::MD5.hexdigest(content)
      self.transaction do
        record = find_or_initialize_by_name name
        unless record.persisted?
          image_attrs.map{ |k,v| record[k] = v if %w[size width height].include? k }
          record.image_type = ::ActsAsImageStore::TYPE_TO_EXT[image_attrs['type'].to_sym.upcase]
          if temporary
            record.refcount = 0
            record.keep_till = Time.now + (ActsAsImageStore.options[:upload_cache] || 3600)
          else
            record.refcount = 1
          end
          record.save!
          filename = name+'.'+record['image_type']
          storage.store filename, content
          filename
        else
          if temporary
            record.keep_till = Time.now + (ActsAsImageStore.options[:upload_cache] || 3600)
          else
            record.refcount += 1
          end
          record.save
          filename = name+'.'+record['image_type']
        end
      end
    end
    ##
    # 画像を保存し、keyを返します。
    #
    def store_image(data, options={})
      save_image(parse_image(data, options), options)
    end

    ##
    # 確認画面経由で一時保存されているデータを確定
    #
    def commit_image(key)
      return unless key.is_a?(String) && !key.empty?
      name, ext = key.split('.')
      self.transaction do
        record = find_by_name name
        raise ActsAsImageStore::ImageNotFound unless record
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
        # 指定された画像キーを持つレコードが見つからなかったら何もせず戻る
        return unless record
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
      [self::CONTENT_TYPES[format.to_sym], retrieve_image(name, format, size, :url)]
    end

    ##
    # 指定されたキーを持つ画像のデータを取得して返す。
    #
    def fetch_data(name, format, size='raw')
      [self::CONTENT_TYPES[format.to_sym], retrieve_image(name, format, size, :fetch)]
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
      key = Array.wrap(key).uniq
      names = key.map{|k| k.split('.').first }
      key.count == where(:name => names).count
    end

    protected

    ##
    # Store resized image and passes parameters to given block
    #
    def retrieve_image(name, format, size, method)
      record = find_by_name(name)
      raise ActsAsImageStore::ImageNotFound unless record

      # check whether size is allowd
      raise ActsAsImageStore::SizeNotAllowed unless size_allowed?(size)

      size = 'raw' unless resize_needed? record, format, size

      begin
        return cache.send(method, name, format, size)
      rescue ActsAsImageStore::CacheAdapters::Abstract::NotFoundError
        begin
          img = ::Magick::Image.from_blob(storage.fetch("#{name}.#{record.image_type}")).shift
        rescue MogileFS::Backend::UnknownKeyError
          raise ActsAsImageStore::ImageNotFound
        end
        cache.store name, format, size, resize_image(img, format, size).to_blob
        return cache.send(method, name, format, size)
      end
    end

    ##
    # Resizes image
    #
    def resize_image(img, format, size)
      w, h, method, n = size.scan(/(\d+)x(\d+)([a-z]*)(\d*)/).shift
      w, h, n = [w, h, n].map {|i| i.to_i if i }
      case method
      when 'fill'
        img = resize_with_fill(img, w, h, n, 'black')
      when 'fillw'
        img = resize_with_fill(img, w, h, n, 'white')
      else
        if size != 'raw' && (img.columns > w || img.rows > h)
          img.resize_to_fit! w, h
        end
      end
      new_format = ::ActsAsImageStore::EXT_TO_TYPE[format.to_sym]
      img.format = new_format if img.format != new_format
      img
    end
    ##
    # Resizes image with background color
    #
    def resize_with_fill(img, w, h, n, color)
      n ||= 0
      img.resize_to_fit! w-n*2, h-n*2
      background = ::Magick::Image.new(w, h) { self.background_color = color }
      background.composite(img, Magick::CenterGravity, Magick::OverCompositeOp)
    end
    ##
    # Check if resize is needed with given size/format
    #
    def resize_needed?(record, format, size)
      return false if size == 'raw'

      # needed if size given
      w, h, method = size.scan(/(\d+)x(\d+)([a-z]*\d*)/).shift
      return true if method && !method.empty?

      # compare given format with original format
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
      ActsAsImageStore.options[:allowed_sizes].each do |item|
        if item.is_a? Regexp
          return true if size.match(item)
        else
          return true if size == item
        end
      end
      return false
    end

    ##
    # deletes image
    #
    def purge_image_data(name)
      if ActsAsImageStore.backend['reproxy']
        urls = []
        storage.list(name).each do |k|
          key, format = k.split('.')
          urls.push(cache.url(key, format, 'raw'))
        end
        cache.list(name).each do |k|
          urls.push(cache.url(name, k.first, k.last))
        end
        urls.unique

        return if urls.size <= 0

        base = URI.parse(ActsAsImageStore.backend['base_url'])
        if ActsAsImageStore.backend['perlbal']
          host, port = ActsAsImageStore.backend['perlbal'].split(':')
          port ||= 80
        else
          host, port = [base.host, base.port]
        end
        # Request asynchronously
        t = Thread.new(host, port, base, urls.join(' ')) do |conn_host, conn_port, perlbal, body|
          Net::HTTP.start(conn_host, conn_port) do |http|
            http.post(perlbal.path + 'flush', body, {
              ActsAsImageStore::AUTH_HEADER => ActsAsImageStore.auth_key(body),
              'Host' => perlbal.host + (perlbal.port != 80 ? ':' + perlbal.port.to_s : ''),
            })
          end
        end
      end
      storage.remove(name)
      cache.remove(name)
    end
  end
end
