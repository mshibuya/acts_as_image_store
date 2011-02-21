namespace :mogile_image_store do
  task :prepare do
    require 'active_support/core_ext/numeric'
    require 'mogilefs'
    require File.expand_path('config/initializers/mogile_image_store.rb', Rails.root)
    MogileImageStore.configure
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
  task :purge => :environment do
    require 'active_support/core_ext/numeric'
    require 'mogilefs'

    puts "WARNING: ALL STORED IMAGE DATA WILL BE LOST."
    puts "If you really wish to continue, enter 'yes'"
    print ":"
    if STDIN.gets.chop == 'yes'
      puts "Connecting to #{MogileImageStore.backend['hosts']}..."
      MogileImage.destroy_all
      @mogadm = MogileFS::Admin.new :hosts  => MogileImageStore.backend['hosts']
      @mg = MogileFS::MogileFS.new({ :domain => MogileImageStore.backend['domain'],
                                   :hosts  => MogileImageStore.backend['hosts'] })
      puts "Deleting all images..."
      @mg.each_key('') {|k| @mg.delete k }
      puts "Deleting domain #{MogileImageStore.backend['domain']}."
      @mogadm.delete_domain MogileImageStore.backend['domain']
      puts "Complete."
    else
      puts "Operation cancelled."
    end
  end
  task :import, :file, :needs => :environment do |t, args|
    if args[:file]
      file = File.new(args[:file])
      puts "Image saved as:"
      puts MogileImage.store_image(file.read)
    else
      puts "Image file not specified."
      puts "usage: rake mogile_image_store:import[<image file name>]"
    end
  end
  task :remove, :key, :needs => :environment do |t, args|
    if args[:key]
      MogileImage.destroy_image(args[:key])
      puts "Image #{args[:key]} deleted."
    else
      puts "Image key not specified."
      puts "usage: rake mogile_image_store:remove[<image key name>]"
    end
  end
  task :list_key => :environment do
    require 'active_support/core_ext/numeric'
    require 'mogilefs'

    puts "Listing keys in domain #{MogileImageStore.backend['domain']} at #{MogileImageStore.backend['hosts']}:"
    @mg = MogileFS::MogileFS.new({ :domain => MogileImageStore.backend['domain'],
                                   :hosts  => MogileImageStore.backend['hosts'] })
    @mg.each_key('') {|k| puts k }
  end
end

