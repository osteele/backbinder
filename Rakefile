require 'rake/clean'
require 'haml'
require 'dotenv'
Dotenv.load
require './config/database.rb'
require './project'
require './file_source'
require './dropbox_source'
require './publisher'

def project_dirname
  ENV['PROJECT'] || begin STDERR.puts "PROJECT not set"; exit 1; end
end

def current_user
  @user ||= Models::User.first(:email => ENV['DROPBOX_USER'] || 'steele@osteele.com')
  raise "No user named #{ENV['DROPBOX_USER']}" unless @user
  @user
end

def current_project
  project = Project.new(project_dirname)
  project.source = FileSource.new('dbox')
  project.source = DropboxSource.new(current_user.dropbox_access_token, current_user.dropbox_access_secret) if ENV['DROPBOX_USER']
  project
end

task :convert do
  project = current_project
  FileUtils::mkdir_p "build"
  open("build/index.html", 'w') do |f| f << project.index_html(:base => "../#{project.project_path}/") end
end

task :publish do
  project = current_project
  publisher = Publisher.new
  url = publisher.publish(current_user, project)
  puts "Open #{url}"
end

require 'resque/tasks'
require './update_dropbox_folder_list_worker'

task :environment do
  require './config/database'
  require './config/resque'
end

task 'resque:setup' => :environment do
  ENV['QUEUE'] = '*'
  Resque.before_fork = Proc.new do
    DataObjects::Pooling.pools.each { |pool| pool.dispose }
  end
end
