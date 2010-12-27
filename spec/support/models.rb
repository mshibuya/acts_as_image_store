# coding: utf-8

class Tableless < ActiveRecord::Base
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end
end

class ImageAll < Tableless
  column :image, :string
  has_images
  validates_image_type_of :image
end

class ImageJpeg < Tableless
  column :image, :string
  has_images
  validates :image, :image_type => { :type => :jpg }
end

class ImageGif < Tableless
  column :image, :string
  has_images
  validates :image, :image_type => { :type => :gif }
end

class ImagePng < Tableless
  column :image, :string
  has_images
  validates :image, :image_type => { :type => :png }
end

class ImageJpegPng < Tableless
  column :image, :string
  has_images
  validates :image, :image_type => { :type => [:jpg, :png] }
end

class ImageMax20 < Tableless
  column :image, :string
  has_images
  validates :image, :file_size => { :max => 20.kilobytes }
end

class ImageMin20 < Tableless
  column :image, :string
  has_images
  validates :image, :file_size => { :min => 20.kilobytes }
end

class ImageMin20Max40 < Tableless
  column :image, :string
  has_images
  validates :image, :file_size => { :min => 20.kilobytes, :max => 40.kilobytes }
end

class ImageWidthMax500 < Tableless
  column :image, :string
  has_images
  validates :image, :width => { :max => 500 }
end

class ImageWidthMin500 < Tableless
  column :image, :string
  has_images
  validates :image, :width => { :min => 500 }
end

class ImageWidthMin500Max600 < Tableless
  column :image, :string
  has_images
  validates :image, :width => { :min => 500, :max => 600 }
end

class ImageHeightMax500 < Tableless
  column :image, :string
  has_images
  validates :image, :height => { :max => 500 }
end

class ImageHeightMin500 < Tableless
  column :image, :string
  has_images
  validates :image, :height => { :min => 500 }
end

class ImageHeightMin430Max500 < Tableless
  column :image, :string
  has_images
  validates :image, :height => { :min => 430, :max => 500 }
end

