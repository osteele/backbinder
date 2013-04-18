require 'sinatra/reloader' if development?
require './config/database'
require './dropbox_source'

class App < Sinatra::Base
  include ::Models

  configure :development do
    register Sinatra::Reloader
    use BetterErrors::Middleware
    BetterErrors.application_root = File.dirname(__FILE__)
  end

  get '/' do
    redirect '/auth/dropbox' unless session[:uid]
    user = User.get(session[:uid])
    redirect '/auth/dropbox' unless user
    redirect '/waitlist' unless user.authorized
    haml :index
  end

  get '/application.js' do
    coffee :application
  end

  get '/projects.json' do
    content_type 'application/json'
    # return [401, MultiJson.encode(:error => "Unauthorized")] unless params[:id] == session[:uid].to_s
    user = User.get(session[:uid])
    MultiJson.encode(user.projects)
  end

  get '/folders.json' do
    content_type 'application/json'
    # return [401, MultiJson.encode(:error => "Unauthorized")] unless params[:id] == session[:uid].to_s
    user = User.get(session[:uid])
    MultiJson.encode(DropboxSource.new(user).folders('/').map { |name| {:name => name} })
  end

  get '/waitlist' do
    "Welcome to the waitlist."
  end

  get '/auth/:provider/callback' do
    content_type 'text/plain'
    email = request.env['omniauth.auth']['info']['email']
    credentials = request.env['omniauth.auth']['credentials']
    user = User.first_or_create(:email => email)
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

