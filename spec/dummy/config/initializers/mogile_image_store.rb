module MogileImageStore
  class Engine < Rails::Engine

    config.mount_at = '/image/'
    
    config.mogile_fs = YAML::load_file("#{Rails.root}/config/initializers/mogile_fs.yml")

    config.options = {
      # default image size for FormBuilder#image_field
      :field_w => 80,
      :field_h => 80,
      # allowed resizes for image
      :allowed_sizes => [
        '80x80', 'raw',
      ]
    }
  end
end
