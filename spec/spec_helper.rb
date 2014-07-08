# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)

require 'rspec/rails'
require 'database_cleaner'
require 'factory_girl'
FactoryGirl.find_definitions
require 'ffaker'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

require 'spree/testing_support/factories'
require 'spree/testing_support/capybara_ext'
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/preferences'
require 'spree/testing_support/flash'
require 'spree/testing_support/url_helpers'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Spree::TestingSupport::ControllerRequests
  config.include Spree::TestingSupport::Preferences
  config.include Spree::TestingSupport::Flash
  config.include Spree::TestingSupport::UrlHelpers

  # Capybara javascript drivers require transactional fixtures set to false, and we just use DatabaseCleaner to cleanup after each test instead.
  # Without transactional fixtures set to false none of the records created to setup a test will be available to the browser, which runs under a seperate server instance.
  config.use_transactional_fixtures = false

  config.before :suite do
    Spree::Config[:taxcloud_api_login_id] = '9A358A0'
    Spree::Config[:taxcloud_api_key]      = 'AA654725-10B3-4F01-A02F-E8047ADCC9CB'
    Spree::Config[:taxcloud_default_product_tic]  = '00000'
    Spree::Config[:taxcloud_shipping_tic] = '11010'
  end

  config.before :each do
    # Before each spec check if it is a Javascript test and switch between using database transactions or not where necessary.
    DatabaseCleaner.strategy = RSpec.current_example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  # After each spec clean the database.
  config.after :each do
    DatabaseCleaner.clean
  end

  config.color = true
  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
end
