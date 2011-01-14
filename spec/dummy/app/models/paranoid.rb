class Paranoid < ActiveRecord::Base
  has_images
  acts_as_paranoid
end
