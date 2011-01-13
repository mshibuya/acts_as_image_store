module MogileImageStore
  ##
  # 画像をバリデートします。
  #
  # ==== 例:
  #   validates :image, :image_attribute => { :type => [:jpg, :png] }
  #   validates :image, :image_attribute => { :type => [:jpg, :png], :type_message => 'jpeg or png' }
  #   validates :image, :image_attribute => { :type => :jpg, :maxsize = 500.kilobytes, :minwidth => 200, :minheight => 200 }
  #   validates :image, :image_attribute => { :type => :jpg, :width => 500, :height => 420 }
  #   
  #   validates_image_attribute_of :image, :type => :jpg, :width => 500, :height => 420
  # 
  module ValidatesImageAttribute
    extend ActiveSupport::Concern

    class ImageAttributeValidator < ActiveModel::EachValidator # :nodoc:
      def validate_each(record, attribute, value)
        image = record.image_attributes[attribute].symbolize_keys rescue return
        if options[:type]
          typearr = Array.wrap(options[:type]).map{ |i| ::MogileImageStore::EXT_TO_TYPE[i.to_sym] }
          unless typearr.include?(image[:type])
            record.errors[attribute] << (
              options[:type_message] ||
              I18n.translate('mogile_image_store.errors.messages.must_be_image_type') % [typearr.join(',')]
            )
          end
        end
        if options[:maxsize]
          if image[:size] > options[:maxsize]
            record.errors[attribute] << (
              options[:size_message] ||
              I18n.translate('mogile_image_store.errors.messages.size_smaller') % [options[:maxsize]/1024]
            )
          end
        end
        if options[:minsize]
          if image[:size] < options[:minsize]
            record.errors[attribute] << (
              options[:size_message] ||
              I18n.translate('mogile_image_store.errors.messages.size_larger') % [options[:minsize]/1024]
            )
          end
        end
        if options[:maxwidth]
          if image[:width] > options[:maxwidth]
            record.errors[attribute] << (
              options[:width_message] ||
              I18n.translate('mogile_image_store.errors.messages.width_smaller') % [options[:maxwidth]]
            )
          end
        end
        if options[:minwidth]
          if image[:width] < options[:minwidth]
            record.errors[attribute] << (
              options[:width_message] ||
              I18n.translate('mogile_image_store.errors.messages.width_larger') % [options[:minwidth]]
            )
          end
        end
        if options[:width]
          if image[:width] != options[:width]
            record.errors[attribute] << (
              options[:width_message] ||
              I18n.translate('mogile_image_store.errors.messages.width') % [options[:width]]
            )
          end
        end
        if options[:maxheight]
          if image[:height] > options[:maxheight]
            record.errors[attribute] << (
              options[:height_message] ||
              I18n.translate('mogile_image_store.errors.messages.height_smaller') % [options[:maxheight]]
            )
          end
        end
        if options[:minheight]
          if image[:height] < options[:minheight]
            record.errors[attribute] << (
              options[:height_message] ||
              I18n.translate('mogile_image_store.errors.messages.height_larger') % [options[:minheight]]
            )
          end
        end
        if options[:height]
          if image[:height] != options[:height]
            record.errors[attribute] << (
              options[:height_message] ||
              I18n.translate('mogile_image_store.errors.messages.height') % [options[:height]]
            )
          end
        end
      end
    end

    module ClassMethods
      ##
      # 画像をバリデートします（Rails2互換形式）
      #
      def validates_image_attribute_of(*attr_names)
        validates_with ImageAttributeValidator, _merge_attributes(attr_names)
      end
    end
  end
end
