require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe 'Connection' do
  it 'accepts a proc for crowd_config' do
    ::Devise.crowd_logger = true
    ::Devise.crowd_config = Proc.new() {{
      'url' => 'http://localhost:4567/rest',
      'username' => 'foo',
      'password' => 'bar'
    }}
    connection = Devise::Crowd::Connection.new(login: 'user', password: 'user')
    assert_equal true, connection.authorized?
  end
end
