class Confirm < ActiveRecord::Base
  has_image :image, :confirm => true
end
