require 'bundler/setup'
Bundler.require(:default, :web)
Bundler.require(:development) if ENV['RACK_ENV'] == "development"
require './application'

use Rack::Session::Cookie, :secret => 'yuv9vorc7aw7or7i'

use OmniAuth::Builder do
  raise "DROPBOX_APP_KEY must be set" unless ENV['DROPBOX_APP_KEY']
  raise "DROPBOX_APP_SECRET must be set" unless ENV['DROPBOX_APP_SECRET']
  provider :dropbox, ENV['DROPBOX_APP_KEY'], ENV['DROPBOX_APP_SECRET']
end

run App.new
