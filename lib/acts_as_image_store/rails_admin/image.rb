require 'rails_admin/config/fields/base'

module ActsAsImageStore
  module RailsAdmin
    class Image < ::RailsAdmin::Config::Fields::Base
      # Register field type for the type loader
      ::RailsAdmin::Config::Fields::Types::register(self)

      @view_helper = :image_field

      register_instance_option(:formatted_value) do
        ActionView::Base.new.thumbnail(value)
      end
    end
  end
end
