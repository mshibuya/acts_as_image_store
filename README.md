ActsAsImageStore
=================
Description
-----------

Easy-to-use image handling plugin for Rails 3.0
With multiple backend support:

* filesystem (stored as plain file)
* database (stored as blob)
* Amazon S3
* MogileFS (experimental)

Usage
-----

* Add to Gemfile

        gem 'nokogiri'
        gem 'rmagick', :require => 'RMagick'
        gem 'acts_as_image_store', :git => 'git://github.com/mshibuya/acts_as_image_store.git'
        
        $ bundle install
        
        $ rails generate acts_as_image_store
          create  db/migrate/20110824040824_create_stored_image_tables.rb
          remove  tmp/~migration_ready.rb
          create  config/initializers/acts_as_image_store.rb
          create  config/initializers/image_store.yml

* Setup custom configurations

          development:
            reproxy:  false
            base_url: /images/
            mount_at: /images/
            storage:
              adapter:  s3
              access_key_id:     <%= ENV['AMAZON_ACCESS_KEY_ID'] %>
              secret_access_key: <%= ENV['AMAZON_SECRET_ACCESS_KEY'] %>
              bucket: foobar_app
              server: s3-ap-northeast-1.amazonaws.com
            cache:
              adapter: file_system
              
* Add some codes
  * Scaffold

            rails generate scaffold logo:string icon:string

  * Migration

            create_table :foos do |t|
              t.string :logo, :limit => 36
              t.string :icon, :limit => 36
              
              t.timestamps
            end

  * Model

            has_images [:logo, :icon]
  
  * Controller
  
            image_deletable

  * View

            <%= form_for(@foo, :html => { :multipart => true }) do |f| %>
              <div class="field">
                <%= f.label :logo %><br />
                <%= f.image_field :logo %>
              </div>
              <div class="field">
                <%= f.label :icon %><br />
                <%= f.image_field :icon %>
              </div>
            <%= end %>

* And run!
              
License
-------

Released under MIT-LICENSE.
   
