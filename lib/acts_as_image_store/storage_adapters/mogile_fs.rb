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

      def fetch(key)
        begin
          @mogile_fs.get_file_data key
        rescue MogileFS::Backend::UnknownKeyError
          raise NotFoundError
        end
      end

      def store(key, content)
        @mogile_fs.store_content key, @backend['class'], content
      end

      def remove(key)
        begin
          @mogile_fs.each_key(key) do |k|
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
