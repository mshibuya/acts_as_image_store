# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require 'cover_me'
CoverMe.config do |c|
  c.at_exit = Proc.new {}
  c.file_pattern = /(#{c.project.root}\/app\/.+\.rb|#{c.project.root}\/lib\/.+\.rb)/ix
end

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "rspec/rails"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Configure capybara for integration testing
require "capybara/rails"
Capybara.default_driver   = :rack_test
Capybara.default_selector = :css

# generate migration files
require "#{File.dirname(__FILE__)}/../lib/rails/generators/mogile_image_store/mogile_image_store_generator"
Dir["#{File.dirname(__FILE__)}/../db/migrate/*_create_mogile_image_tables.rb"].each { |f| File.unlink f }
MogileImageStoreGenerator.new.create_migration_file
# Run generated migration
ActiveRecord::Migrator.migrate File.expand_path("../../db/migrate/", __FILE__)
# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  # methods or matchers
  require 'rspec/expectations'
  config.include RSpec::Matchers

  # == Mock Framework
  config.mock_with :rspec
end
