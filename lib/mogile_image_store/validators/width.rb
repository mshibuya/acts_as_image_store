module MogileImageStore
  module Validators
    module ValidatesWidth
      extend ActiveSupport::Concern

      class WidthValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          width = record.image_attributes[attribute]['width'] rescue nil
          if options[:max]
            if width > options[:max]
              record.errors[attribute] << (options[:message] ||
                    I18n.translate('mogile_image_store.errors.messages.width_smaller') % [options[:max]])
            end
          end
          if options[:min]
            if width < options[:min]
              record.errors[attribute] << (options[:message] ||
                    I18n.translate('mogile_image_store.errors.messages.width_larger') % [options[:min]])
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
