module MogileImageStore
  module Validators
    module ValidatesImageType
      extend ActiveSupport::Concern

      class ImageTypeValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          type = record.image_attributes[attribute]['type'] rescue return
          if options[:type]
            typearr = Array.wrap(options[:type]).map{ |i| ::MogileImageStore::EXT_TO_TYPE[i.to_sym] }
            unless typearr.include?(type)
              record.errors[attribute] << (options[:message] ||
                              I18n.translate('mogile_image_store.errors.messages.must_be_image_type') % [typearr.join(',')])
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
