module MogileImageStore
  module Validators
    module ValidatesWidth
      extend ActiveSupport::Concern

      class WidthValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          if options[:max]
            unless value['image']['width'] > options[:max]
              record.errors[attribute] << "'s width must be smaller than #{options[:max]} pixels."
            end
          end
          if options[:min]
            unless value['image']['width'] < options[:min]
              record.errors[attribute] << "'s width must be larger than #{options[:min]} pixels."
            end
          end
        end
      end

      module ClassMethods
        def validates_width_of(*attr_names)
          validates_with WidthValidator, _merge_attributes(attr_names)
        end
      end
    end
  end
end
