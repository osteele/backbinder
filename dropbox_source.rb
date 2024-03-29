require 'dropbox_sdk'
require './config/database.rb'

class DropboxSource
  def initialize(access_token, access_secret)
    @access_token = access_token
    @access_secret = access_secret
  end

  def exists?(path)
    # return client.search('Music', path).any? { |entry| entry['path'] == "/Music/#{path}"}
    client.metadata(resolve(path))
    true
  rescue DropboxError => e
    raise unless e.http_response.code == '404'
    false
  end

  def find(path)
    prefix, suffix = resolve(path).split('/**/')
    raise "Can only process * as suffix or prefix" if suffix =~ /^.+\*.+$/
    query = suffix.split('*').join
    client.search(prefix, query).map { |entry| entry['path'].sub(/^\//, '') }
  end

  def open(path, &block)
    StringIO.open(read(path), &block)
  end

  def read(path)
    client.get_file(resolve(path))
  end

  def size(path)
    file_metadata = client.metadata(resolve(path))
    file_metadata['bytes']
  end

  def folders(path)
    client.metadata(path)['contents'].map { |entry| OpenStruct.new(entry) }.select(&:is_dir).map(&:path).map { |path| path[1..-1] }
  end

  private

  attr_reader :access_token, :access_secret

  def resolve(path)
    path # File.join('Music', path)
  end

  def session
    @session ||= begin
      session = DropboxSession.new(ENV['DROPBOX_APP_KEY'], ENV['DROPBOX_APP_SECRET'])
      session.set_access_token access_token, access_secret
      session
    end
  end

  def client
    @client ||= DropboxClient.new(session)
  end
end

if __FILE__ == $0
  p DropboxSource.new.find("Music/**/*.markdown")
  p DropboxSource.new.find('Music/**/*.gif')
  # p DropboxSource.new.exists?('404')
end
