# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "devise_crowd_authenticatable/version"

Gem::Specification.new do |s|
  s.name     = 'devise_crowd_authenticatable'
  s.version  = DeviseCrowdAuthenticatable::VERSION.dup
  s.platform = Gem::Platform::RUBY
  s.summary  = 'Devise extension to allow authentication via Crowd'
  s.email = 'thorsten@muerell.de'
  s.homepage = 'http://muerell.de/'
  s.description = s.summary
  s.authors = ['Thorsten Mürell' ]
  s.license = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('devise', '>= 3.4.1')
  s.add_dependency('rest-client')

  s.add_development_dependency('rake', '>= 0.9')
  s.add_development_dependency('rdoc', '>= 3')
  s.add_development_dependency('rails', '~> 4.0')
  s.add_development_dependency('sqlite3')
  s.add_development_dependency('factory_girl_rails', '~> 1.0')
  s.add_development_dependency('factory_girl', '~> 2.0')
  s.add_development_dependency('rspec-rails')
  s.add_development_dependency('sinatra')

  %w{database_cleaner capybara launchy}.each do |dep|
    s.add_development_dependency(dep)
  end
end
