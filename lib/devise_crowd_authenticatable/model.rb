require 'devise_crowd_authenticatable/strategy'

module Devise
  module Models
    # Crowd Module, responsible for validating the user credentials via Crowd.
    #
    # Examples:
    #
    #    User.authenticate('email@test.com', 'password123')  # returns authenticated user or nil
    #    User.find(1).valid_password?('password123')         # returns true/false
    #
    module CrowdAuthenticatable
      extend ActiveSupport::Concern

      included do
        attr_reader :current_password, :password
        attr_accessor :password_confirmation
      end

      def login_with
        @login_with ||= Devise.mappings.find {|k,v| v.class_name == self.class.name}.last.to.authentication_keys.first
        self[@login_with]
      end

      def change_password!(current_password)
        raise "Need to set new password first" if @password.blank?

        Devise::Crowd::Adapter.update_own_password(login_with, @password, current_password)
      end
      
      def reset_password!(new_password, new_password_confirmation)
        if new_password == new_password_confirmation && ::Devise.crowd_update_password
          Devise::Crowd::Adapter.update_password(login_with, new_password)
        end
        clear_reset_password_token if valid?
        save
      end

      def password=(new_password)
        @password = new_password
        if defined?(password_digest) && @password.present? && respond_to?(:encrypted_password=)
          self.encrypted_password = password_digest(@password) 
        end
      end

      # Checks if a resource is valid upon authentication.
      def valid_crowd_authentication?(password)
        Devise::Crowd::Adapter.valid_credentials?(login_with, password)
      end

      def crowd_entry
        @crowd_entry ||= Devise::Crowd::Adapter.get_crowd_entry(login_with)
      end

      def crowd_groups
        Devise::Crowd::Adapter.get_groups(login_with)
      end

      def in_crowd_group?(group_name)
        Devise::Crowd::Adapter.in_crowd_group?(login_with, group_name)
      end

      def crowd_dn
        crowd_entry ? crowd_entry.dn : nil
      end

      def crowd_get_param(param)
        if crowd_entry && !crowd_entry[param].empty?
          value = crowd_entry.send(param)
        else
          nil
        end
      end

      #
      # callbacks
      #

      # # Called before the crowd record is saved automatically
      # def crowd_before_save
      # end

      # Called after a successful Crowd authentication
      def after_crowd_authentication
      end


      module ClassMethods
        # Find a user for crowd authentication.
        def find_for_crowd_authentication(attributes={})
          auth_key = self.authentication_keys.first
          return nil unless attributes[auth_key].present?

          auth_key_value = (self.case_insensitive_keys || []).include?(auth_key) ? attributes[auth_key].downcase : attributes[auth_key]
      	  auth_key_value = (self.strip_whitespace_keys || []).include?(auth_key) ? auth_key_value.strip : auth_key_value

          resource = where(auth_key => auth_key_value).first

          if resource.blank?
            resource = new
            resource[auth_key] = auth_key_value
            resource.password = attributes[:password]
          end

          if ::Devise.crowd_create_user && resource.new_record? && resource.valid_crowd_authentication?(attributes[:password])
            resource.crowd_before_save if resource.respond_to?(:crowd_before_save)
            resource.save!
          end

          resource
        end

        def update_with_password(resource)
          puts "UPDATE_WITH_PASSWORD: #{resource.inspect}"
        end

      end
    end
  end
end
