require 'sinatra/reloader' if development?
require './config/database'
require './project'
require './publisher'
require './dropbox_source'
require './firebase'

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

  get '/user/info.json' do
    content_type 'application/json'
    user = User.get(session[:uid])
    MultiJson.encode(
      :id => user.id,
      :email => user.email,
      :token => Firebase.create_token({:uid => user.id})
    )
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
    folder_names = DropboxSource.new(user.dropbox_access_token, user.dropbox_access_secret).folders('/').map { |name| {:name => name} }
    Firebase.set("users/#{user.id}/folders", folder_names)
    MultiJson.encode(folder_names)
  end

  post '/folder/publish' do
    user = User.get(session[:uid])
    params = JSON.parse(request.env['rack.input'].read)
    project = ::Project.new(params['name'])
    project.source = DropboxSource.new(user.dropbox_access_token, user.dropbox_access_secret)
    publisher = Publisher.new
    publisher.publish(user, project)
    "ok"
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

