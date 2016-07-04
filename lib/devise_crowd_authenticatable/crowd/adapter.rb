module Devise
  module Crowd
    DEFAULT_GROUP_UNIQUE_MEMBER_LIST_KEY = 'uniqueMember'
    
    module Adapter
      def self.valid_credentials?(login, password_plaintext)
        options = {:login => login,
                   :password => password_plaintext,
                   :crowd_auth_username_builder => ::Devise.crowd_auth_username_builder,
                   :admin => ::Devise.crowd_use_admin_to_bind}

        resource = Devise::Crowd::Connection.new(options)
        resource.authorized?
      end

      def self.update_password(login, new_password)
        options = {:login => login,
                   :new_password => new_password,
                   :crowd_auth_username_builder => ::Devise.crowd_auth_username_builder,
                   :admin => ::Devise.crowd_use_admin_to_bind}

        resource = Devise::Crowd::Connection.new(options)
        resource.change_password! if new_password.present?
      end

      def self.crowd_connect(login)
        options = {:login => login}

        resource = Devise::Crowd::Connection.new(options)
      end

      def self.valid_login?(login)
        self.crowd_connect(login).valid_login?
      end

      def self.get_groups(login)
        self.crowd_connect(login).user_groups
      end

      def self.in_crowd_group?(login, group_name)        
        self.crowd_connect(login).in_group?(group_name)
      end

      def self.get_crowd_entry(login)
        self.crowd_connect(login).search_for_login
      end

    end

  end

end
