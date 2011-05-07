# coding: utf-8

module ActsAsImageStore
  module CacheAdapters
    class Abstract
      class NotImplementedError < StandardError ; end
      class NotSupportedError < StandardError ; end
      class NotFoundError < StandardError ; end

      cattr_accessor :loaded

      class << self
        def load(klass) ; end
      end

      def initialize(backend)
        @backend = backend
      end

      def exist?(key, format, size)
        raise NotImplementedError, '#exist? is not implemented'
      end

      def list(key)
        raise NotImplementedError, '#list_keys is not implemented'
      end

      def fetch(key, format, size)
        raise NotImplementedError, '#fetch is not implemented'
      end

      def url(key, format, size)
        raise NotImplementedError, '#url is not implemented'
      end

      def store(key, format, size, content)
        raise NotImplementedError, '#store is not implemented'
      end

      def remove(key)
        raise NotImplementedError, '#remove is not implemented'
      end

      def purge
        raise NotImplementedError, '#purge is not implemented'
      end
    end
  end
end

