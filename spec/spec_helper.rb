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

require "factory_girl"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Configure capybara for integration testing
require "capybara/rails"
Capybara.default_driver   = :rack_test
Capybara.default_selector = :css

# generate migration files
require "#{File.dirname(__FILE__)}/../lib/rails/generators/acts_as_image_store/acts_as_image_store_generator"
Dir["#{File.dirname(__FILE__)}/dummy/db/migrate/*_create_stored_image_tables.rb"].each { |f| File.unlink f }
#save current directory
cwd = Dir.pwd
Dir.chdir File.expand_path("../dummy/", __FILE__)
generator = ActsAsImageStoreGenerator.new
generator.create_migration_file
Dir.chdir cwd
# Run any available migration
ActiveRecord::Migration.suppress_messages do
  ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)
end
# Load initializer
require "#{File.dirname(__FILE__)}/dummy/config/initializers/acts_as_image_store.rb"

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  # methods or matchers
  require 'rspec/expectations'
  config.include RSpec::Matchers

  # == Mock Framework
  config.mock_with :rspec

  require "database_cleaner"
  include MogilefsHelperMethods
  config.before(:each) do
    if example.metadata[:mogilefs]
      mogilefs_prepare
      @mg = MogileFS::MogileFS.new({
        :domain => ActsAsImageStore.backend['domain'],
        :hosts  => ActsAsImageStore.backend['hosts']
      })
    end
    if example.metadata[:truncation]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
  end
  config.after(:each) do
    mogilefs_cleanup if example.metadata[:mogilefs]
    DatabaseCleaner.clean
  end

  # filtering
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
