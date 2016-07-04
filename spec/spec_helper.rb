ENV["RAILS_ENV"] = "test"

require File.expand_path("rails_app/config/environment.rb",  File.dirname(__FILE__))
require 'rspec/rails'
#require 'rspec/autorun'
require 'factory_girl' # not sure why this is not already required

# Rails 4.1 and RSpec are a bit on different pages on who should run migrations
# on the test db and when.
#
# https://github.com/rspec/rspec-rails/issues/936
if defined?(ActiveRecord::Migration) && ActiveRecord::Migration.respond_to?(:maintain_test_schema!)
  ActiveRecord::Migration.maintain_test_schema!
end

Dir[File.expand_path("support/**/*.rb", File.dirname(__FILE__))].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
#  config.expect_with(:rspec) { |c| c.syntax = :should }
end

def default_devise_settings!
  ::Devise.crowd_logger = true
  ::Devise.crowd_create_user = false
  ::Devise.crowd_update_password = true
  ::Devise.crowd_config = "#{Rails.root}/config/crowd.yml"
  ::Devise.crowd_check_group_membership = false
  ::Devise.crowd_check_attributes = false
  ::Devise.crowd_auth_username_builder = Proc.new() {|attribute, login, crowd| "#{attribute}=#{login},#{ldap.base}" }
  ::Devise.authentication_keys = [:email]
end
