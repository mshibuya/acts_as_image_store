# coding: utf-8

module ActsAsImageStore
  module CacheAdapters
    class FileSystem < Abstract
      def initialize(backend)
        backend[:path] ||= ActsAsImageStore.backend[:mount_at].
          gsub(/(?:^\/|\/$)/, '')
        super
      end

      def exist?(key, format, size)
        File.exist?(path(key, format, size))
      end

      def list(key)
        Dir.glob(path(key, '*', '*')).map do |f|
          s = Regexp.quote([File::SEPARATOR, File::ALT_SEPARATOR].join)
          f.match(/([^#{s}]+)#{s}[^#{s}\.]+\.(.+)$/).to_a.slice(1,2).reverse
        end
      end

      def fetch(key, format ,size)
        begin
          File.read(path(key, format, size))
        rescue
          raise NotFoundError
        end
      end

      def store(key, format, size, content)
        dir = path(nil, nil, size)
        FileUtils.mkdir_p(dir) unless File.directory?(dir)
        file = File.open(path(key, format, size), 'w:ASCII-8BIT')
        file.write(content)
        file.close
      end

      def remove(key)
        Dir.glob(path(key, '*', '*')) do |f|
          File.unlink f
        end
      end

      def purge
        Dir.glob(path('*', '*', '*')) do |f|
          File.unlink f
        end
      end

      def url(key, format, size)
        ["/#{@backend['path']}/#{size}/#{key}.#{format}"]
      end

      private

      def path(key, format, size)
        if key || format
          File.join(Rails.public_path, @backend['path'], size, "#{key}.#{format}")
        else
          File.join(Rails.public_path, @backend['path'], size)
        end
      end
    end
  end
end
