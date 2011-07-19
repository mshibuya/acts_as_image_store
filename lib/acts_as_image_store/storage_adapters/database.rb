# coding: utf-8

module ActsAsImageStore
  module StorageAdapters
    class Database < Abstract
      def exist?(key)
        !!StoredImage.find_by_name(key.split('.').first).try(:data)
      end

      def list_keys(prefix='')
        name, ext = prefix.split('.')
        query = StoredImage.where('name LIKE ?', "#{name}%").where('data IS NOT NULL')
        query = query.where('image_type LIKE ?', "#{ext}%") if ext
        query.all.map{|r| r.to_key}
      end

      def fetch(record)
        record.data
      end

      def store(record, content)
        record['data'] = content
      end

      def remove(record)
        record['data'] = nil
      end

      def purge
        StoredImage.all.each do |r|
          r['data'] = nil
          r.save
        end
      end
    end
  end
end
