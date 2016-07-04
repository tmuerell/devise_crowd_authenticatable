require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'

DENIED = [ 403, "Access denied" ]

def check_authorization(auth)
  # username:foo, password: bar
  auth == "Basic Zm9vOmJhcg=="
end

def find_user(username)
  if username == 'barneystinson'
    [400, {}, '{"reason":"INVALID_USER","message":"Account with name <'+username+'> failed to authenticate"}']
  else
    [200, {}, '{"expand":"attributes","name":"'+username+'","active":true,"first-name":"Test","last-name":"User","display-name":"Test User","email":"testuser@example.com"}']
  end
end

post '/rest/usermanagement/1/authentication.json' do
  return DENIED unless check_authorization(request.env['HTTP_AUTHORIZATION'])
  
  data = JSON.parse(request.body.read)
  
  username = params[:username]
  password = data['value']
  
  special_users = { 'EXAMPLE.user@test.com' => 'secret',
                    'example.user@test.com' => 'secret',
                    'example.admin@test.com' => 'admin_secret'}
  
  if username =~ /^DOMAIN\\/
    if password != "other_secret"
      return [400, {}, '{"reason":"INVALID_USER_AUTHENTICATION","message":"Account with name <'+username+'> failed to authenticate"}']
    end
  elsif special_users[username]
    if password != special_users[username]
      return [400, {}, '{"reason":"INVALID_USER_AUTHENTICATION","message":"Account with name <'+username+'> failed to authenticate"}']
    end
  else
    if username != password
      return [400, {}, '{"reason":"INVALID_USER_AUTHENTICATION","message":"Account with name <'+username+'> failed to authenticate"}']
    end
  end
  
  find_user(params[:username])
end

def valid_group_answer(groups)
    [200, {}, {expand: 'group', groups: groups.map { |s| { name: s }}}.to_json]
end

get '/rest/usermanagement/1/user/group/direct.json' do
  return DENIED unless check_authorization(request.env['HTTP_AUTHORIZATION'])
  
  username = params[:username]
  
  if username == 'example.admin@test.com'
    valid_group_answer(%w{admin-group user-group})
  else
    valid_group_answer(%w{sc-operations mo-operations user-group})
  end
end

get '/rest/usermanagement/1/user.json' do
  return DENIED unless check_authorization(request.env['HTTP_AUTHORIZATION'])
  
  find_user(params[:username])
end
