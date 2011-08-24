require 'rails_admin/config/fields/base'

module ActsAsImageStore
  module RailsAdmin
    class MultipleImage < ::RailsAdmin::Config::Fields::Base
      # Register field type for the type loader
      ::RailsAdmin::Config::Fields::Types::register(self)

      @view_helper = :multiple_image_field

      register_instance_option(:formatted_value) do
        '[IMAGES]'
      end
    end
  end
end
