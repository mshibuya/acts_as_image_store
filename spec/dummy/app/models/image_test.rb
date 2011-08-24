class ImageTest < ActiveRecord::Base
  has_image [:image, :image2]

  belongs_to :confirm
end
