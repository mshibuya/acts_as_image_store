# coding: utf-8
require 'aws/s3'

module ActsAsImageStore
  module CacheAdapters
    class S3 < Abstract
      def initialize(backend)
        AWS::S3::Base.establish_connection!(
          :access_key_id     => backend['access_key_id'],
          :secret_access_key => backend['secret_access_key'],
          :server => backend['server'] || "s3.amazonaws.com",
        )                                                  
        @bucket = AWS::S3::Bucket.find(backend['bucket'])  
        super                                     
      end

      def exist?(key, format, size)
        AWS::S3::S3Object.exists? path(key, format, size), @backend['bucket']
      end

      def list(key)
        @bucket.reject do |i|                     
          File.basename(i.key)[0, key.length] != key
        end.map do |obj|
          obj.key.match(/([^\/]+)\/[^\/\.]+\.(.+)$/).to_a.slice(1,2).reverse
        end
      end

      def fetch(key, format ,size)
        begin
          AWS::S3::S3Object.find(path(key, format, size), @backend['bucket']).value
        rescue AWS::S3::NoSuchKey                 
          raise NotFoundError
        end
      end

      def store(key, format, size, content)
        ext = key.split('.').pop
        AWS::S3::S3Object.store(
          path(key, format, size), content, @backend['bucket'],
          :content_type => ::StoredImage::CONTENT_TYPES[ext]
        )
      end

      def remove(key)
        @bucket.reject do |i|                     
          File.basename(i.key)[0, key.length] != key
        end.each do |obj|
          obj.delete
        end
      end

      def purge
        @bucket.delete_all
      end

      def url(key, format, size)
        if @backend['web']
          ["#{@backend['web']}#{size}/#{key}.#{format}"]
        else
          raise NotSupportedError
        end
      end

      private

      def path(key, format, size)
        if key || format
          File.join(size, "#{key}.#{format}")
        else
          File.join(size)
        end
      end
    end
  end
end
