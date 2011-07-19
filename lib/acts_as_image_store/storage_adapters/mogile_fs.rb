# coding: utf-8
require 'mogilefs'

module ActsAsImageStore
  module StorageAdapters
    class MogileFS < Abstract
      def initialize(backend)
        @mogile_fs = MogileFS::MogileFS.new({
          :domain => backend[:domain],
          :hosts  => backend[:hosts],
        })
        super
      end

      def list_keys(prefix='')
        @mogile_fs.list_keys(prefix).shift
      end

      def fetch(record)
        begin
          @mogile_fs.get_file_data record.to_key
        rescue MogileFS::Backend::UnknownKeyError
          raise NotFoundError
        end
      end

      def store(record, content)
        @mogile_fs.store_content record.to_key, @backend['class'], content
      end

      def remove(record)
        begin
          @mogile_fs.each_key(record.to_key) do |k|
            @mogile_fs.delete k
          end
        rescue MogileFS::Backend::UnknownKeyError
          raise NotFoundError
        end
      end

      def purge
        remove ''
      end
    end
  end
end
