# coding: utf-8

module ActsAsImageStore
  module CacheAdapters
    class External < Abstract

      def exist?(key, format, size)
        false
      end

      def list(key)
        []
      end

      def fetch(key, format, size)
        raise NotFoundError       
      end

      def url(key, format, size)
        ["/#{ActsAsImageStore.backend['base_url']}#{size}/#{key}.#{format}"]
      end

      def store(key, format, size, content)
      end

      def remove(key)
        # TODO: kick external hook
      end

      def purge
      end
    end
  end
end

