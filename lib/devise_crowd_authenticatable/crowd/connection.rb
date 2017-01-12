require 'rest-client'
require 'json'

module Devise
  module Crowd
    class Connection
      attr_reader :crowd, :login

      def initialize(params = {})
        if ::Devise.crowd_config.is_a?(Proc)
          crowd_config = ::Devise.crowd_config.call
        else
          crowd_config = YAML.load(ERB.new(File.read(::Devise.crowd_config || "#{Rails.root}/config/crowd.yml")).result)[Rails.env]
        end
        crowd_options = params
        
        options = {}
        options[:verify_ssl] = crowd_config['verify_ssl'] if crowd_config['verify_ssl']

        @crowd = RestClient::Resource.new crowd_config['url'], crowd_config['username'], crowd_config['password']

        @check_group_membership = crowd_config.has_key?("check_group_membership") ? crowd_config["check_group_membership"] : ::Devise.crowd_check_group_membership
        @required_groups = crowd_config["required_groups"]

        @login = params[:login]
        @password = params[:password]
        @new_password = params[:new_password]
      end
      
      def authenticate!
        begin
          JSON.parse(@crowd['/usermanagement/1/authentication.json?username=' + @login].post '{ "value": "' + @password.gsub(/"/, '\"') + '" }', :content_type => 'application/json', 'Accept' => 'application/json')
        rescue Object => e
          DeviseCrowdAuthenticatable::Logger.send("ERROR: #{e.inspect}")
          false
        end
      end

      def authenticated?
        authenticate!
      end

      def authorized?
        DeviseCrowdAuthenticatable::Logger.send("Authorizing user #{@login}")
        if !authenticated?
          DeviseCrowdAuthenticatable::Logger.send("Not authorized because not authenticated.")
          return false
        elsif !in_required_groups?
          DeviseCrowdAuthenticatable::Logger.send("Not authorized because not in required groups.")
          return false
        else
          return true
        end
      end

      def change_password!
        update_crowd(:userpassword => Net::Crowd::Password.generate(:sha, @new_password))
      end

      def in_required_groups?
        return true unless @check_group_membership

        ## FIXME set errors here, the crowd.yml isn't set properly.
        return false if @required_groups.nil?
        
        for group in @required_groups
          return false unless in_group?(group)
        end
        return true
      end

      def in_group?(group_name)
        unless user_groups.include?(group_name)
          DeviseCrowdAuthenticatable::Logger.send("User #{@login} is not in group: #{group_name}")
          return false
        end

        return true
      end

      def user_groups
        groups = JSON.parse(@crowd['/usermanagement/1/user/group/direct.json?username=' + @login].get(:content_type => 'application/json', 'Accept' => 'application/json'))
        
        groups["groups"].map { |g| g['name'] }
      end

      def valid_login?
        !search_for_login.nil?
      end

      # Searches the Crowd for the login
      #
      # @return [Object] the Crowd entry found; nil if not found
      def search_for_login
        @login_crowd_entry ||= begin
          user = JSON.parse(@crowd['/usermanagement/1/user.json?username=' + @login].get(:content_type => 'application/json', 'Accept' => 'application/json')) rescue nil 
        end
      end

    end
  end
end
