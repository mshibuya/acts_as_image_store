# coding: utf-8
require 'RMagick'

module MogileImageStore
  class Resizer
    def self.new(content)
      @img = ::Magick::Image.from_blob(content).shift
      self
    end

    def resize(width, height)
      @img.resize_to_fit!(width, height)
      self
    end

    def convert(format)
      type = ::MogileImageStore::EXT_TO_TYPE[format]
      @img.format = type if @img.format != type
      self
    end

    def data
      @img.to_blob
    end

    def image
      @img
    end
  end
end
