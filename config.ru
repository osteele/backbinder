require 'bundler/setup'
Bundler.require :default, :web
Bundler.require :development if ENV['RACK_ENV'] == 'development'
require 'sprockets'
require './application'

use Rack::Session::Cookie, :secret => 'yuv9vorc7aw7or7i'

use OmniAuth::Builder do
  raise "DROPBOX_APP_KEY must be set" unless ENV['DROPBOX_APP_KEY']
  raise "DROPBOX_APP_SECRET must be set" unless ENV['DROPBOX_APP_SECRET']
  provider :dropbox, ENV['DROPBOX_APP_KEY'], ENV['DROPBOX_APP_SECRET']
end

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'app'
  run environment
end

map '/' do
  run App.new
end

