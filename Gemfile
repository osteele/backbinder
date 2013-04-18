source 'https://rubygems.org'

gem 'rake'

group :web do
  gem 'rack'
  gem 'sinatra'
  gem 'omniauth'
  gem 'omniauth-dropbox'
  gem 'multi_json', '~> 1.0.3' # required by omniauth-dropbox; data_mapper can't work with recent versions
  gem 'coffee-script'
  gem 'haml'
end

group :database do
  gem 'data_mapper', '~> 1.2.0' # default install is too old
  gem 'dm-postgres-adapter'
end

group :sources do
  gem 'dropbox-sdk'
  gem 'safe_yaml'
end

group :publication do
  gem 'redcarpet'
  gem 'haml'
  gem 'aws-s3'
end

group :development do
  gem 'dm-sqlite-adapter'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'foreman'
  gem 'sinatra-contrib'
  gem 'pry'
  gem 'shotgun'
end
