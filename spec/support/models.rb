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

class ImageJpegOldForm < Tableless
  column :image, :string
  has_images
  validates_image_type_of :image, :type => :jpg
end

class ImageJpegCustomMsg < Tableless
  column :image, :string
  has_images
  validates :image, :image_type => { :type => :jpg, :message => "custom" }
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

class ImageMax20OldForm < Tableless
  column :image, :string
  has_images
  validates_file_size_of :image, :max => 20.kilobytes
end

class ImageMax20CustomMsg < Tableless
  column :image, :string
  has_images
  validates :image, :file_size => { :max => 20.kilobytes, :message => 'custom' }
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

class ImageWidthMax500OldForm < Tableless
  column :image, :string
  has_images
  validates_width_of :image, :max => 500
end

class ImageWidthMax500CustomMsg < Tableless
  column :image, :string
  has_images
  validates :image, :width => { :max => 500, :message => 'custom' }
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

class ImageHeightMax500OldForm < Tableless
  column :image, :string
  has_images
  validates_height_of :image, :max => 500
end

class ImageHeightMax500CustomMsg < Tableless
  column :image, :string
  has_images
  validates :image, :height => { :max => 500, :message => 'custom' }
end

class ImageTestWithImageType < ActiveRecord::Base
  self.table_name = 'image_tests'
  has_images
  validates :image, :image_type => { :type => [:jpg, :png] }
end

class ImageTestWithFileSize < ActiveRecord::Base
  self.table_name = 'image_tests'
  has_images
  validates :image, :file_size => { :max => 20.kilobytes }
end

class ImageTestWithWidth < ActiveRecord::Base
  self.table_name = 'image_tests'
  has_images
  validates :image, :width => { :max => 500 }
end

class ImageTestWithHeight < ActiveRecord::Base
  self.table_name = 'image_tests'
  has_images
  validates :image, :height => { :max => 500 }
end
