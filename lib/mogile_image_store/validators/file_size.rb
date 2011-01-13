module MogileImageStore
  module ValidatesFileSize
    extend ActiveSupport::Concern

    class FileSizeValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        size = record.image_attributes[attribute]['size'] rescue return
        if options[:max]
          if size > options[:max]
            record.errors[attribute] << (options[:message] ||
                                         I18n.translate('mogile_image_store.errors.messages.size_smaller') % [options[:max]/1024])
          end
        end
        if options[:min]
          if size < options[:min]
            record.errors[attribute] << (options[:message] ||
                                         I18n.translate('mogile_image_store.errors.messages.size_larger') % [options[:min]/1024])
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
