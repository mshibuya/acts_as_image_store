class Multiple < ActiveRecord::Base
  has_multiple_images MultiplePhoto => :photo

  belongs_to :confirm
end
