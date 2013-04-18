require './config/database'
require './config/resque'
require 'resque'
require 'resque-loner'
require './firebase'

class PublicationWorker
  include Resque::Plugins::UniqueJob
  @queue = :publication

  def self.perform(project_id)
    project_model = Models::Project.get(project_id)
    user = project_model.user
    project = Project.new(project_model.name)
    project.source = DropboxSource.new(user.dropbox_access_token, user.dropbox_access_secret)
    publisher = Publisher.new
    publisher.publish(user, project)
  end
end
