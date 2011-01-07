namespace :mogile_image_store do
  task :prepare do
    require File.expand_path('config/initializers/mogile_image_store.rb', Rails.root)
    require 'mogilefs'
    puts "Connecting to #{MogileImageStore.backend['hosts']}..."
    mogadm = MogileFS::Admin.new :hosts => MogileImageStore.backend['hosts']
    #create domain
    domains = mogadm.get_domains
    if domains[MogileImageStore.backend['domain']]
      puts "Domain #{MogileImageStore.backend['domain']} already exists."
    else
      mogadm.create_domain MogileImageStore.backend['domain']
      puts "Created domain #{MogileImageStore.backend['domain']}."
    end
    # create class
    print "Input mindevcount for class #{MogileImageStore.backend['class']}:"
    mindevcount = STDIN.gets
    begin
      mogadm.create_class MogileImageStore.backend['domain'], MogileImageStore.backend['class'], mindevcount
      puts "Created class #{MogileImageStore.backend['class']}."
    rescue
      puts "Class #{MogileImageStore.backend['class']} already exists."
    end
  end
end

