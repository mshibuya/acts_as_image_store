class MultiplePhoto < ActiveRecord::Base
  belongs_to :multiple

  has_image :photo
end
