require 'bundler/setup'
require 'sinatra/base'
require 'omniauth-dropbox'
require './config/database'
require './dropbox_source'

class App < Sinatra::Base
  get '/' do
    redirect '/auth/dropbox' unless session[:uid]
    user = ::User.get(session[:uid])
    redirect '/auth/dropbox' unless user
    redirect '/waitlist' unless user.authorized
    "Okay!"
    DropboxSource.new(user).folders('/').inspect
  end

  get '/waitlist' do
    "Welcome to the waitlist."
  end

  get '/auth/:provider/callback' do
    content_type 'text/plain'
    # https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema
    email = request.env['omniauth.auth']['info']['email']
    credentials = request.env['omniauth.auth']['credentials']
    user = ::User.first_or_create(:email => email)
    user.attributes = {
        :dropbox_access_token => credentials.token,
        :dropbox_access_secret => credentials.secret
      }
    user.save
    session[:uid] = user.id
    redirect request.env['omniauth.origin'] || '/'
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
