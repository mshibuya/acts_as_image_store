module MogileImageStore
  class Engine < Rails::Engine

    config.mount_at = '/image/'
        
  end
end
