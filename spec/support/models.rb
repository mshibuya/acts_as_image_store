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

class ImageMaxTwenty < Tableless
  column :image, :string
  has_images
  validates :image, :file_size => { :max => 20.kilobytes }
end

class ImageMinTwenty < Tableless
  column :image, :string
  has_images
  validates :image, :file_size => { :min => 20.kilobytes }
end

class ImageMinTwentyMaxFourty < Tableless
  column :image, :string
  has_images
  validates :image, :file_size => { :min => 20.kilobytes, :max => 40.kilobytes }
end

class ImageWidthMaxFive < Tableless
  column :image, :string
  has_images
  validates :image, :width => { :max => 500 }
end

class ImageWidthMinFive < Tableless
  column :image, :string
  has_images
  validates :image, :width => { :min => 500 }
end

class ImageWidthMinFiveMaxSix < Tableless
  column :image, :string
  has_images
  validates :image, :width => { :min => 500, :max => 600 }
end

class ImageHeightMaxFive < Tableless
  column :image, :string
  has_images
  validates :image, :height => { :max => 500 }
end

class ImageHeightMinFive < Tableless
  column :image, :string
  has_images
  validates :image, :height => { :min => 500 }
end

class ImageHeightMinFourThirtyMaxFive < Tableless
  column :image, :string
  has_images
  validates :image, :height => { :min => 430, :max => 500 }
end

