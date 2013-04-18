require 'data_mapper'

DataMapper::Logger.new($stdout, :info)
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/development.sqlite")
DataMapper.repository(:default).adapter.resource_naming_convention = DataMapper::NamingConventions::Resource::UnderscoredAndPluralizedWithoutModule

module Models
  class User
    include DataMapper::Resource

    has n, :projects

    property :id, Serial
    property :email, String, :length => 256, :required => true, :unique_index => true
    property :authorized, Boolean, :required => true, :default => false
    property :dropbox_access_token, String
    property :dropbox_access_secret, String
  end

  class Project
    include DataMapper::Resource

    belongs_to :user, :unique_index => :user_and_name

    property :id, Serial
    property :name, String, :length => 256, :required => true, :unique_index => :user_and_name
    property :published_at, DateTime
    property :public_url, String
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!
