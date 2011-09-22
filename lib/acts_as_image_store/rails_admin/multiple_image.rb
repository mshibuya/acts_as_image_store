require 'rails_admin/config/fields/base'

module ActsAsImageStore
  module RailsAdmin
    class MultipleImage < ::RailsAdmin::Config::Fields::Base
      # Register field type for the type loader
      ::RailsAdmin::Config::Fields::Types::register(self)

      @view_helper = :multiple_image_field

      register_instance_option(:formatted_value) do
        mi_map = bindings[:object].multiple_image_config
        bindings[:object].send(@name).map do |item|
          bindings[:view].thumbnail item.send(mi_map[item.class])
        end.join(" ").html_safe
      end
    end
  end
end
