require './config/database'
require './config/resque'
require 'resque'
require 'resque-loner'
require './firebase'

class UpdateDropboxFolderListWorker
  include Resque::Plugins::UniqueJob
  @queue = :dropbox_reader

  def self.perform(user_id)
    user = ::Models::User.get(user_id)
    folder_names = DropboxSource.new(user.dropbox_access_token, user.dropbox_access_secret).folders('/').map { |name| {:name => name} }
    Firebase.set("users/#{user.id}/folders", folder_names)
    MultiJson.encode(folder_names)
  end
end
