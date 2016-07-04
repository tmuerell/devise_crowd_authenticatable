require 'rubygems'
require 'bundler/setup'

require 'devise_crowd_authenticatable'

    ::Devise.crowd_config = Proc.new() {{
      'url' => 'http://localhost:4567/rest',
      'username' => 'foo',
      'password' => 'bar'
    }}


conn = Devise::Crowd::Connection.new(username: 'user', password: 'xxx')

puts conn.authenticated?
