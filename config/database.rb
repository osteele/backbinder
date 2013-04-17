require 'data_mapper'

DataMapper::Logger.new($stdout, :info)
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/development.sqlite")

class User
  include DataMapper::Resource

  property :id, Serial
  property :email, String, :length => 256, :required => true, :unique_index => true
  property :authorized, Boolean, :required => true, :default => false
  property :dropbox_access_token, String
  property :dropbox_access_secret, String
end

DataMapper.finalize
DataMapper.auto_upgrade!
