module MogileImageStore
  class Engine < Rails::Engine

    config.mount_at = '/image/'

    config.mogile_fs = YAML::load_file("#{Rails.root}/config/initializers/mogile_fs.yml")

    config.options = {
      # default image size for FormBuilder#image_field
      :field_w => 80,
      :field_h => 80,
      # global maximum uploadable filesize in byte
      :maxsize => 5.megabytes,
      # allowed resizes for image
      :allowed_sizes => [
        # no resizing
        'raw',
        # resizing
        '80x80',
        '88x31',
        # resizing with fill
        '40x40fill1',
        # regexp can also be used
        # /^\d+0x\d+0$/,
      ],
      # temporal image expiry time when confirmation is enabled
      :upload_cache = 1.day,
    }
  end
end
