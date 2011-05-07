# coding: utf-8
require 'aws/s3'

module ActsAsImageStore
  module StorageAdapters
    class S3 < Abstract
      def initialize(backend)
        AWS::S3::Base.establish_connection!(
          :access_key_id     => backend['access_key_id'],
          :secret_access_key => backend['secret_access_key'],
          :server => "s3-ap-northeast-1.amazonaws.com",
        )
        @bucket = AWS::S3::Bucket.find(backend['bucket'])
        super
      end

      def exist?(key)
        AWS::S3::S3Object.exists? key, @backend['bucket']
      end

      def list_keys(prefix='')
        @bucket.reject do |i|
          i.key[0, prefix.length] != prefix
        end.map{|i| i.key }
      end

      def fetch(key)
        begin
          AWS::S3::S3Object.find(key, @backend['bucket']).value
        rescue AWS::S3::NoSuchKey
          raise NotFoundError
        end
      end

      def store(key, content)
        name, ext = key.split('.')
        AWS::S3::S3Object.store(
          key, content, @backend['bucket'],
          :content_type => ::StoredImage::CONTENT_TYPES[ext]
        )
      end

      def remove(key)
        AWS::S3::S3Object.delete key, @backend['bucket']
      end

      def purge
        @bucket.delete_all
      end
    end
  end
end
