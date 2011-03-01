class Confirm < ActiveRecord::Base
  has_image :image, :confirm => true

  has_many :multiples
end
