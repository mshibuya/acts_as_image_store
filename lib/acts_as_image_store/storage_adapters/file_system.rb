# coding: utf-8

module ActsAsImageStore
  module StorageAdapters
    class FileSystem < Abstract
      def initialize(backend)
        super
        @backend['path'] ||= ActsAsImageStore.backend[:mount_at].
          gsub(/(?:^\/|\/$)/, '')
      end

      def exist?(key)
        File.exist?(path(key))
      end

      def list_keys(prefix='')
        Dir.glob(path("#{prefix}*")).map do |f|
          File.basename f
        end
      end

      def fetch(record)
        begin
          File.open(path(record.to_key), 'rb:ASCII-8BIT') do |file|
            file.read
          end
        rescue
          raise NotFoundError
        end
      end

      def store(record, content)
        dir = path('')
        FileUtils.mkdir_p(dir) unless File.directory?(dir)
        File.open(path(record.to_key), 'wb:ASCII-8BIT') do |file|
          file.write(content)
        end
      end

      def remove(record)
        Dir.glob(path(record.to_key)) do |f|
          File.unlink f
        end
      end

      def purge
        Dir.glob(path('*')) do |f|
          File.unlink f
        end
      end

      private

      def path(key)
        File.join(Rails.public_path, @backend['path'], 'raw', key)
      end
    end
  end
end
