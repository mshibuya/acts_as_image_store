# coding: utf-8

class Tableless < ActiveRecord::Base
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end
end

class ImageJpeg < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :type => :jpg }
end

class ImageGif < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :type => :gif }
end

class ImagePng < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :type => :png }
end

class ImageJpegPng < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :type => [:jpg, :png] }
end

class ImageJpegOldForm < Tableless
  column :image, :string
  has_images
  validates_image_attribute_of :image, :type => :jpg
end

class ImageJpegCustomMsg < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :type => :jpg, :type_message => "custom" }
end

class ImageMax20 < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :maxsize => 20.kilobytes }
end

class ImageMin20 < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :minsize => 20.kilobytes }
end

class ImageMin20Max40 < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :minsize => 20.kilobytes, :maxsize => 40.kilobytes }
end

class ImageMax20OldForm < Tableless
  column :image, :string
  has_images
  validates_image_attribute_of :image, :maxsize => 20.kilobytes
end

class ImageMax20CustomMsg < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :maxsize => 20.kilobytes, :size_message => 'custom' }
end

class ImageWidthMax500 < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :maxwidth => 500 }
end

class ImageWidthMin500 < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :minwidth => 500 }
end

class ImageWidthMin500Max600 < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :minwidth => 500, :maxwidth => 600 }
end

class ImageWidthMax500OldForm < Tableless
  column :image, :string
  has_images
  validates_image_attribute_of :image, :maxwidth => 500
end

class ImageWidthMax500CustomMsg < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :maxwidth => 500, :width_message => 'custom' }
end

class ImageWidth513 < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :width => 513 }
end

class ImageHeightMax500 < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :maxheight => 500 }
end

class ImageHeightMin500 < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :minheight => 500 }
end

class ImageHeightMin430Max500 < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :minheight => 430, :maxheight => 500 }
end

class ImageHeightMax500OldForm < Tableless
  column :image, :string
  has_images
  validates_image_attribute_of :image, :maxheight => 500
end

class ImageHeightMax500CustomMsg < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :maxheight => 500, :height_message => 'custom' }
end

class ImageHeight420 < Tableless
  column :image, :string
  has_images
  validates :image, :image_attribute => { :height => 420 }
end

class ImageTestWithImageType < ActiveRecord::Base
  self.table_name = 'image_tests'
  has_images
  validates :image, :image_attribute => { :type => [:jpg, :png] }
end

class ImageTestWithFileSize < ActiveRecord::Base
  self.table_name = 'image_tests'
  has_images
  validates :image, :image_attribute => { :maxsize => 20.kilobytes }
end

class ImageTestWithWidth < ActiveRecord::Base
  self.table_name = 'image_tests'
  has_images
  validates :image, :image_attribute => { :maxwidth => 500 }
end

class ImageTestWithHeight < ActiveRecord::Base
  self.table_name = 'image_tests'
  has_images
  validates :image, :image_attribute => { :maxheight => 500 }
end
