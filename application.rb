require 'sinatra/reloader' if development?
require './config/database'
require './config/resque'
require './project'
require './publisher'
require './dropbox_source'
require './firebase'
require './update_dropbox_folder_list_worker'
require './publication_worker'

class App < Sinatra::Base
  include ::Models

  configure :development do
    register Sinatra::Reloader
    Dir['**/*.rb'].each do |file| also_reload file end
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
    Resque.enqueue UpdateDropboxFolderListWorker, session[:uid]
    "queued"
  end

  post '/folder/publish' do
    user = User.get(session[:uid])
    params = JSON.parse(request.env['rack.input'].read)
    project = Models::Project.first_or_create(:user => user, :name => params['name'])
    Resque.enqueue PublicationWorker, project.id
    "queued"
  end

  post '/project/publish' do
    params = JSON.parse(request.env['rack.input'].read)
    project = Models::Project.get(params['id'])
    Resque.enqueue PublicationWorker, project.id
    "queued"
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

