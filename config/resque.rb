require 'resque'
require 'resque/server'

ENV["REDISTOGO_URL"] ||= "redis://localhost/"

uri = URI.parse(ENV["REDISTOGO_URL"])
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, :thread_safe => true)

if RESQUE_PASSWORD
  Resque::Server.class_eval do
    use Rack::Auth::Basic do |email, password|
      password == RESQUE_PASSWORD
    end
  end
end
