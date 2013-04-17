require 'bundler/setup'
require 'sinatra/base'
require 'omniauth-dropbox'
require 'sinatra/reloader' if [nil, 'development'].include?(ENV['RACK_ENV'])

class App < Sinatra::Base
  get '/' do
    redirect '/auth/dropbox'
  end

  get '/auth/:provider/callback' do
    content_type 'text/plain'
    credentials = request.env['omniauth.auth']['credentials']
    "Token: #{credentials.token}\nSecret: #{credentials.secret}"
  end

  get '/auth/failure' do
    content_type 'application/json'
    MultiJson.encode(request.env)
  end
end

use Rack::Session::Cookie, :secret => 'yuv9vorc7aw7or7i'

use OmniAuth::Builder do
  provider :dropbox, ENV['DROPBOX_APP_KEY'], ENV['DROPBOX_APP_SECRET']
end

run App.new
