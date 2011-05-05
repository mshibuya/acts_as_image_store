# coding: utf-8
require 'mogilefs'

module ActsAsImageStore
  module StorageAdapters
    class FileSystem < Abstract
      def initialize(backend)
        super
      end

      def exist?(key)
        p (File.join(Rails.root, @backend['path'], key))
        File.exist?(File.join(Rails.root, @backend['path'], key))
      end

      def list_keys(prefix)
        Dir.glob(File.join(Rails.root, @backend['path'], "#{prefix}*")).map do |f|
          File.basename f
        end
      end

      def fetch(key)
        begin
          File.read(File.join(Rails.root, @backend['path'], key))
        rescue
          raise NotFoundError
        end
      end

      def store(key, content)
        file = File.open(File.join(Rails.root, @backend['path'], key), 'w')
        file.write(content)
        file.close
      end

      def remove(key)
        begin
          File.unlink File.join(Rails.root, @backend['path'], key)
        rescue
          raise NotFoundError
        end
      end

      def purge
        Dir.glob(File.join(Rails.root, @backend['path'], '*')) do |f|
          File.unlink f
        end
      end
    end
  end
end
