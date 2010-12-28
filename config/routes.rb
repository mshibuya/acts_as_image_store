Rails.application.routes.draw do
  mount_at = MogileImageStore::Engine.config.mount_at rescue '/image/'

  match "#{mount_at}:size/:name.:format", :to => "mogile_images#show", :constraints => {
    :size => /(raw|\d*x\d*)/,
    :name =>/[0-9a-f]{0,32}/,
    :format =>/(jpg|gif|png)/,
  }
end
