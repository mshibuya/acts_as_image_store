module MogileImageStore
  module Validators
    module ValidatesHeight
      extend ActiveSupport::Concern

      class HeightValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          height = record.image_attributes[attribute]['height'] rescue nil
          if options[:max]
            if height > options[:max]
              record.errors[attribute] << (options[:message] ||
                    I18n.translate('mogile_image_store.errors.messages.height_smaller') % [options[:max]])
            end
          end
          if options[:min]
            if height < options[:min]
              record.errors[attribute] << (options[:message] ||
                    I18n.translate('mogile_image_store.errors.messages.height_larger') % [options[:min]])
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
