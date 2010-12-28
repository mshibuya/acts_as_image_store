module MogileImageStore
  class Engine < Rails::Engine

    config.mount_at = '/image/'
        
    config.mogile_fs = {
      :development => {
        :hosts   => %w[192.168.56.101:7001],
        :domain  => 'dev',
        :class   => 'image',
        :reproxy => false,
      },
      :test => {
        :hosts   => %w[192.168.56.101:7001],
        :domain  => 'mogile_image_store_test',
        :class   => 'test',
        :reproxy => false,
      },
      :production => {
        :hosts   => %w[192.168.56.101:7001 192.168.56.102:7001],
        :domain  => 'xxx',
        :class   => 'xxx',
        :reproxy => 7.days,
      },
    }
  end
end
