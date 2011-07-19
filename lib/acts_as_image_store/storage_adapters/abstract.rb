# coding: utf-8

module ActsAsImageStore
  module StorageAdapters
    class Abstract
      class NotImplementedError < StandardError ; end
      class NotFoundError < StandardError ; end

      cattr_accessor :loaded

      class << self
        def load(klass) ; end
      end

      def initialize(backend=nil)
        @backend = backend || {}
      end

      def exist?(key)
        raise NotImplementedError, '#exist? is not implemented'
      end

      def list_keys(prefix='')
        raise NotImplementedError, '#list_keys is not implemented'
      end

      def fetch(record)
        raise NotImplementedError, '#fetch is not implemented'
      end

      def store(record, content)
        raise NotImplementedError, '#store is not implemented'
      end

      def remove(record)
        raise NotImplementedError, '#remove is not implemented'
      end

      def purge
        raise NotImplementedError, '#purge is not implemented'
      end
    end
  end
end

