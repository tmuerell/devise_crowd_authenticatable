require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe 'Users' do

  def should_be_validated(user, password, message = "Password is invalid")
    assert(user.valid_crowd_authentication?(password), message)
  end

  def should_not_be_validated(user, password, message = "Password is not properly set")
     assert(!user.valid_crowd_authentication?(password), message)
  end

  describe "With default settings" do
    before do
      default_devise_settings!
    end

    describe "look up and crowd user" do
      it "should return true for a user that does exist in Crowd" do
        assert_equal true, ::Devise::Crowd::Adapter.valid_login?('example.user@test.com')
      end

      it "should return false for a user that doesn't exist in Crowd" do
        assert_equal false, ::Devise::Crowd::Adapter.valid_login?('barneystinson')
      end
    end

    describe "create a basic user" do
      before do
        @user = Factory.create(:user)
      end

      it "should check for password validation" do
        assert_equal(@user.email, "example.user@test.com")
        should_be_validated @user, "secret"
        should_not_be_validated @user, "wrong_secret"
        should_not_be_validated @user, "Secret"
      end
    end

    describe "create new local user if user is in Crowd" do

      before do
        assert(User.all.blank?, "There shouldn't be any users in the database")
      end

      it "should not create user in the database" do
        @user = User.find_for_crowd_authentication(:email => "example.user@test.com", :password => "secret")
        assert(User.all.blank?)
        assert(@user.new_record?)
      end

      describe "creating users is enabled" do
        before do
          ::Devise.crowd_create_user = true
        end

        it "should create a user in the database" do
          @user = User.find_for_crowd_authentication(:email => "example.user@test.com", :password => "secret")
          assert_equal(User.all.size, 1)
          User.all.collect(&:email).should include("example.user@test.com")
          assert(@user.persisted?)
        end

        it "should not create a user in the database if the password is wrong_secret" do
          @user = User.find_for_crowd_authentication(:email => "example.user", :password => "wrong_secret")
          assert(User.all.blank?, "There's users in the database")
        end

        it "should not create a user if the user is not in Crowd" do
          @user = User.find_for_crowd_authentication(:email => "wrong_secret.user@test.com", :password => "wrong_secret")
          assert(User.all.blank?, "There's users in the database")
        end

        it "should create a user in the database if case insensitivity does not matter" do
          ::Devise.case_insensitive_keys = []
          @user = Factory.create(:user)

          expect do
            User.find_for_crowd_authentication(:email => "EXAMPLE.user@test.com", :password => "secret")
          end.to change { User.count }.by(1)
        end

        it "should not create a user in the database if case insensitivity matters" do
          ::Devise.case_insensitive_keys = [:email]
          @user = Factory.create(:user)

          expect do
            User.find_for_crowd_authentication(:email => "EXAMPLE.user@test.com", :password => "secret")
          end.to_not change { User.count }
        end

        it "should create a user with downcased email in the database if case insensitivity matters" do
          ::Devise.case_insensitive_keys = [:email]

          @user = User.find_for_crowd_authentication(:email => "EXAMPLE.user@test.com", :password => "secret")
          User.all.collect(&:email).should include("example.user@test.com")
        end
      end

    end

    describe "use groups for authorization" do
      before do
        @admin = Factory.create(:admin)
        @user = Factory.create(:user)
        ::Devise.authentication_keys = [:email]
        ::Devise.crowd_check_group_membership = true
      end

      it "should admin should be allowed in" do
        should_be_validated @admin, "admin_secret"
      end

      it "should admin should have the proper groups set" do
        @admin.crowd_groups.should include('admin-group')
      end
    end
    
    describe "check group membership" do
      before do
        @admin = Factory.create(:admin)
        @user = Factory.create(:user)
      end
      
      it "should return true for admin being in the admins group" do
        assert_equal true, @admin.in_crowd_group?('admin-group')
      end
      
      it "should return true for user being in the users group" do
        assert_equal true, @user.in_crowd_group?('sc-operations')
      end   
      
      it "should return false for user being in the admins group" do
        assert_equal false, @user.in_crowd_group?('admin-group')
      end

      it "should return false for a user being in a nonexistent group" do
        assert_equal false, @user.in_crowd_group?('thisgroupdoesnotexist')
      end
    end

    describe "check group membership" do
      before do
        @user = Factory.create(:user)
      end

      it "should return true for user being in the users group" do
        assert_equal true, @user.in_crowd_group?('sc-operations')
      end

      it "should return false for user being in the admins group" do
        assert_equal false, @user.in_crowd_group?('admin-group')
      end

      it "should return false for a user being in a nonexistent group" do
        assert_equal false, @user.in_crowd_group?('thisgroupdoesnotexist')
      end
    end

  end


  describe "using ERB in the config file" do
    before do
      default_devise_settings!
      ::Devise.crowd_config = "#{Rails.root}/config/crowd_with_erb.yml"
    end

    describe "authenticate" do
      before do
        @admin = Factory.create(:admin)
        @user = Factory.create(:user)
      end

      it "should be able to authenticate" do
        should_be_validated @user, "secret"
        should_be_validated @admin, "admin_secret"
      end
    end
  end
end
