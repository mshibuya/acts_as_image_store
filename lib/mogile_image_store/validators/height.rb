module MogileImageStore
  module Validators
    module ValidatesHeight
      extend ActiveSupport::Concern

      class HeightValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          if options[:max]
            unless value['image']['height'] > options[:max]
              record.errors[attribute] << "'s height must be smaller than #{options[:max]} pixels."
            end
          end
          if options[:min]
            unless value['image']['height'] < options[:min]
              record.errors[attribute] << "'s height must be larger than #{options[:min]} pixels."
            end
          end
        end
      end

      module ClassMethods
        def validates_height_of(*attr_names)
          validates_with HeightValidator, _merge_attributes(attr_names)
        end
      end
    end
  end
end
