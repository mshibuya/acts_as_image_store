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
    content = image_attrs['content']
    name = Digest::MD5.hexdigest(content)
    self.transaction do
      record = find_or_initialize_by_name name
      unless record.persisted?
        image_attrs.map{ |k,v| record[k] = v if %w[size width height].include? k }
        record.image_type = ::MogileImageStore::TYPE_TO_EXT[image_attrs['type'].to_sym.upcase]
        record.refcount = 1
        record.save!
        filename = name+'.'+record['image_type']
        mg = mogilefs_connect
        mg.store_content filename, MogileImageStore.config[:class], content
        filename
      else
        record.refcount += 1
        record.save
        filename = name+'.'+record['image_type']
      end
    end
  end

  def self.destroy_image(key)
    name, ext = key.split('.')
    self.transaction do
      record = find_by_name name
      raise MogileImageStore::ImageNotFound unless record
      if record.refcount > 1
        record.refcount -= 1
        record.save
      else
        record.delete
        #delete all size/type of images of given hash name
        mg = mogilefs_connect
        mg.each_key(name){|k| mg.delete k }
      end
    end
  end

  CONTENT_TYPES = HashWithIndifferentAccess.new ({
    :jpg => 'image/jpeg',
    :gif => 'image/gif',
    :png => 'image/png',
  })
  def self.fetch_urls(name, format=nil, size='raw')
    content_type, key = get_key(name, format, size)
    urls = mogilefs_connect.get_paths key
    [ content_type, urls ]
  end

  def self.fetch_data(name, format=nil, size='raw')
    content_type, key = get_key(name, format, size)
    data = mogilefs_connect.get_file_data key
    [ content_type, data ]
  end

  def self.get_key(name, format, size)
    record = find_by_name(name)
    raise ActiveRecord::RecordNotFound unless record
    if size == 'raw'
      w = h = 0
    else
      w, h = size.scan(/(\d*)x(\d*)/).shift.map{|i| i.to_i}
    end
    if (w == 0 || w > record.width) && (h == 0 || h > record.height)
      #needs no resizing
      suffix = ""
    else
      suffix = "/#{w}x#{h}"
    end
    format = record.image_type unless format
    key = "#{name}.#{format}#{suffix}"
    mg = mogilefs_connect
    begin
      mg.size(key)
    rescue
      # image not exists. generate
      img = ::Magick::Image.from_blob(mg.get_file_data("#{name}.#{record.image_type}")).shift
      img.resize_to_fit! w, h if w > 0 || h > 0
      new_format = ::MogileImageStore::EXT_TO_TYPE[format.to_sym]
      img.format = new_format if img.format != new_format
      mg.store_content key, MogileImageStore.config[:class], img.to_blob
    end
    return [self::CONTENT_TYPES[format.to_sym], key]
  end

  def self.mogilefs_connect
    begin
      return @@mogilefs
    rescue
      @@mogilefs = MogileFS::MogileFS.new({
        :domain => MogileImageStore.config[:domain],
        :hosts  => MogileImageStore.config[:hosts],
      })
    end
  end
end
