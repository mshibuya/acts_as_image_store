# coding: utf-8
require 'aws/s3'

module ActsAsImageStore
  module StorageAdapters
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

      def exist?(key)
        AWS::S3::S3Object.exists? key, @backend['bucket']
      end

      def list_keys(prefix='')
        @bucket.reject do |i|
          i.key[0, prefix.length] != prefix
        end.map{|i| i.key }
      end

      def fetch(record)
        begin
          AWS::S3::S3Object.find(record.to_key, @backend['bucket']).value
        rescue AWS::S3::NoSuchKey
          raise NotFoundError
        end
      end

      def store(record, content)
        AWS::S3::S3Object.store(
          record.to_key, content, @backend['bucket'],
          :content_type => ::StoredImage::CONTENT_TYPES[record.image_type]
        )
      end

      def remove(record)
        AWS::S3::S3Object.delete record.to_key, @backend['bucket']
      end

      def purge
        @bucket.delete_all
      end
    end
  end
end
