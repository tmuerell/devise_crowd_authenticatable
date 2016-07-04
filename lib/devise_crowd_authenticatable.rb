# encoding: utf-8
require 'devise'

require 'devise_crowd_authenticatable/exception'
require 'devise_crowd_authenticatable/logger'
require 'devise_crowd_authenticatable/crowd/adapter'
require 'devise_crowd_authenticatable/crowd/connection'

# Get crowd information from config/crowd.yml now
module Devise
  # Allow logging
  mattr_accessor :crowd_logger
  @@crowd_logger = true
  
  # Add valid users to database
  mattr_accessor :crowd_create_user
  @@crowd_create_user = false
  
  # A path to YAML config file or a Proc that returns a
  # configuration hash
  mattr_accessor :crowd_config
  # @@crowd_config = "#{Rails.root}/config/crowd.yml"
  
  mattr_accessor :crowd_update_password
  @@crowd_update_password = true
  
  mattr_accessor :crowd_check_group_membership
  @@crowd_check_group_membership = false
  
  mattr_accessor :crowd_check_attributes
  @@crowd_check_role_attribute = false
  
  mattr_accessor :crowd_use_admin_to_bind
  @@crowd_use_admin_to_bind = false
  
  mattr_accessor :crowd_auth_username_builder
  @@crowd_auth_username_builder = Proc.new() {|attribute, login, crowd| "#{attribute}=#{login},#{crowd.base}" }

  mattr_accessor :crowd_ad_group_check
  @@crowd_ad_group_check = false
end

# Add crowd_authenticatable strategy to defaults.
#
Devise.add_module(:crowd_authenticatable,
                  :route => :session, ## This will add the routes, rather than in the routes.rb
                  :strategy   => true,
                  :controller => :sessions,
                  :model  => 'devise_crowd_authenticatable/model')
