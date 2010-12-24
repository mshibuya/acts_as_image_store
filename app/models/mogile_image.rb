# coding: utf-8 
require 'mogilefs'
require 'digest/md5'

class MogileImage < ActiveRecord::Base
  SHORTEST_HASH_LENGTH = 7
  def create_unique_hash(name)
    start = self::SHORTEST_HASH_LENGTH
    for i in start..31
      record = self.unscoped.select("1").where('name = ?', name[0,i]).first
      return name[0,i] if !record
    end
    hash
  end

  def self.save_image(image_attrs)
    mg = MogileFS::MogileFS.new :domain => 'hoge', :hosts => %w[192.168.56.101:7001]
    content = image_attrs['content']
    name = Digest::MD5.hexdigest(content)
    record = image_attrs.reject { |k,v| !%w[size width height].include? k }
    record['imgtype'] = ::MogileImageStore::TYPE_TO_EXT[image_attrs['type'].to_sym.upcase]
    record['name'] = name
    if self.create record
      filename = name+'.'+record['imgtype']
      mg.store_content filename, 'fuga', content
      filename
    else
      nil
    end
  end

  CONTENT_TYPES = HashWithIndifferentAccess.new ({
    :jpg => 'image/jpeg',
    :gif => 'image/gif',
    :png => 'image/png',
  })
  def self.fetch_urls(name, format, size)
    key = get_key(name, format, size)
    mg = mogilefs_connect
    urls = mg.get_paths "#{name}.#{format}"
    [ self::CONTENT_TYPES[format], urls ]
  end

  def self.fetch_data(name, format, size)
    key = get_key(name, format, size)
    data = mg.get_file_data "#{name}.#{format}"
    [ self::CONTENT_TYPES[format], data ]
  end

  def self.get_key(name, format, size)
    mg = mogilefs_connect
    record = find_by_name(name)
    raise ActiveRecord::RecordNotFound unless record
    if size == 'raw'
      w = h = 0
    else
      w, h = size.scan(/(\d*)x(\d*)/).shift.map{|i| i.to_i}
    end
    if (w == 0 || w <= record.witdh) && (h == 0 || h <= record.height)
      #needs no resizing
      suffix = ""
    else
      suffix = "/#{w}x#{h}"
    end
    key = "#{name}.#{format}#{suffix}"
    unless mg.list_keys(key, nil, 1)
      # image not exists. generate
      img = ::Magick::Image.from_blob(mg.get_file_data("#{name}.#{record.imgtype}")).shift
      img.resize_to_fit! w, h if w > 0 || h > 0
      new_format = ::MogileImageStore::EXT_TO_TYPE[format.to_sym]
      img.format = new_format if img.format != new_format
      mg.store_file key, 'fuga', img.to_blob
    end
    return key
  end

  def self.mogilefs_connect
    return @@mogilefs if @@mogilefs
    @@mogilefs = MogileFS::MogileFS.new :domain => 'hoge', :hosts => %w[192.168.56.101:7001]
    return @@mogilefs
  end
end
