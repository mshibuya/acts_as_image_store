module MogileImageStore
  module Validators
    module ValidatesImageType
      extend ActiveSupport::Concern

      class ImageTypeValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          type = record.image_attributes[attribute]['type'] rescue nil
          if options[:type]
            unless type == options[:type]
              record.errors[attribute] << I18n.translate('mogile_image_store.errors.messages.must_be_image_type') % [options[:type]]
            end
          else
            unless ::MogileImageStore::IMAGE_FORMATS.include?(type)
              record.errors[attribute] << I18n.translate('mogile_image_store.errors.messages.must_be_image')
            end
          end
        end
      end

      module ClassMethods
        def validates_image_type_of(*attr_names)
          validates_with ImageTypeValidator, _merge_attributes(attr_names)
        end
      end
    end
  end
end
