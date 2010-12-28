namespace :mogile_image_store do
  task :prepare do
    require File.expand_path('config/initializers/mogile_image_store.rb', Rails.root)
    require 'mogilefs'
    puts "Connecting to #{MogileImageStore.config[:hosts]}..."
    mogadm = MogileFS::Admin.new :hosts => MogileImageStore.config[:hosts]
    #create domain
    domains = mogadm.get_domains
    if domains[MogileImageStore.config[:domain]]
      puts "Domain #{MogileImageStore.config[:domain]} already exists."
    else
      mogadm.create_domain MogileImageStore.config[:domain]
      puts "Created domain #{MogileImageStore.config[:domain]}."
    end
    # create class
    print "Input mindevcount for class #{MogileImageStore.config[:class]}:"
    mindevcount = STDIN.gets
    begin 
      mogadm.create_class MogileImageStore.config[:domain], MogileImageStore.config[:class], mindevcount
      puts "Created class #{MogileImageStore.config[:class]}."
    rescue
      puts "Class #{MogileImageStore.config[:class]} already exists."
    end
  end
end

