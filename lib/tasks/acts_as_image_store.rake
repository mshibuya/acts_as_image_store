namespace :acts_as_image_store do
  task :prepare do
    require 'active_support/core_ext/numeric'
    require 'mogilefs'
    require File.expand_path('config/initializers/acts_as_image_store.rb', Rails.root)
    ActsAsImageStore.configure
    puts "Connecting to #{ActsAsImageStore.backend['hosts']}..."
    mogadm = MogileFS::Admin.new :hosts => ActsAsImageStore.backend['hosts']
    #create domain
    domains = mogadm.get_domains
    if domains[ActsAsImageStore.backend['domain']]
      puts "Domain #{ActsAsImageStore.backend['domain']} already exists."
    else
      mogadm.create_domain ActsAsImageStore.backend['domain']
      puts "Created domain #{ActsAsImageStore.backend['domain']}."
    end
    # create class
    print "Input mindevcount for class #{ActsAsImageStore.backend['class']}:"
    mindevcount = STDIN.gets
    begin
      mogadm.create_class ActsAsImageStore.backend['domain'], ActsAsImageStore.backend['class'], mindevcount
      puts "Created class #{ActsAsImageStore.backend['class']}."
    rescue
      puts "Class #{ActsAsImageStore.backend['class']} already exists."
    end
  end
  task :purge => :environment do
    require 'active_support/core_ext/numeric'
    require 'mogilefs'

    puts "WARNING: ALL STORED IMAGE DATA WILL BE LOST."
    puts "If you really wish to continue, enter 'yes'"
    print ":"
    if STDIN.gets.chop == 'yes'
      puts "Connecting to #{ActsAsImageStore.backend['hosts']}..."
      StoredImage.destroy_all
      @mogadm = MogileFS::Admin.new :hosts  => ActsAsImageStore.backend['hosts']
      @mg = MogileFS::MogileFS.new({ :domain => ActsAsImageStore.backend['domain'],
                                   :hosts  => ActsAsImageStore.backend['hosts'] })
      puts "Deleting all images..."
      @mg.each_key('') {|k| @mg.delete k }
      puts "Deleting domain #{ActsAsImageStore.backend['domain']}."
      @mogadm.delete_domain ActsAsImageStore.backend['domain']
      puts "Complete."
    else
      puts "Operation cancelled."
    end
  end
  task :import, [:file] => [:environment] do |t, args|
    p args
    if args[:file]
      file = File.new(args[:file])
      puts "Image saved as:"
      puts StoredImage.store_image(file.read)
    else
      puts "Image file not specified."
      puts "usage: rake acts_as_image_store:import[<image file name>]"
    end
  end
  task :remove, [:key] => [:environment] do |t, args|
    if args[:key]
      StoredImage.destroy_image(args[:key])
      puts "Image #{args[:key]} deleted."
    else
      puts "Image key not specified."
      puts "usage: rake acts_as_image_store:remove[<image key name>]"
    end
  end
  task :list_key => :environment do
    require 'active_support/core_ext/numeric'
    require 'mogilefs'

    puts "Listing keys in domain #{ActsAsImageStore.backend['domain']} at #{ActsAsImageStore.backend['hosts']}:"
    @mg = MogileFS::MogileFS.new({ :domain => ActsAsImageStore.backend['domain'],
                                   :hosts  => ActsAsImageStore.backend['hosts'] })
    @mg.each_key('') {|k| puts k }
  end
  namespace "install" do
    task :view do
      ActsAsImageStore::Task.copy_view_files
    end
  end
end

