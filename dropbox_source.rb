require 'dropbox_sdk'

class DropboxSource
  def initialize
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
    query = suffix.split('*').join # TODO error if wildcard anywhere except beginning or end
    client.search(prefix, query).map { |entry| entry['path'].sub(/^\//, '') }
  end

  def open(path)
    StringIO.open(read(path))
  end

  def read(path)
    client.get_file(resolve(path))
  end

  def size(path)
    file_metadata = client.metadata(resolve(path))
    file_metadata['bytes']
  end

  private

  def resolve(path)
    path # File.join('Music', path)
  end

  def session
    @session ||= begin
      session = DropboxSession.new(ENV['DROPBOX_APP_KEY'], ENV['DROPBOX_APP_SECRET'])
      session.set_access_token ENV['DROPBOX_ACCESS_TOKEN'], ENV['DROPBOX_ACCESS_SECRET']
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
