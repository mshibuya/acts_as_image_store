module MogileImageStore
  module Validators
    module ValidatesFileSize
      extend ActiveSupport::Concern

      class FileSizeValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          size = record.image_attributes[attribute]['size'] rescue nil
          if options[:max]
            if size > options[:max]
              record.errors[attribute] << "must be smaller than #{options[:max] / 1000}KB."
            end
          end
          if options[:min]
            if size < options[:min]
              record.errors[attribute] << "must be larger than #{options[:min] / 1000}KB."
            end
          end
        end
      end

      module ClassMethods
        def validates_file_size_of(*attr_names)
          validates_with FileSizeValidator, _merge_attributes(attr_names)
        end
      end
    end
  end
end
