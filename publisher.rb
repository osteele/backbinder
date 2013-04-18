require 'uri'
require 'aws/s3'
require './config/database.rb'

class Publisher
  attr_reader :bucket_name

  def initialize
    @bucket_name = 'assets.matterfront.com'
  end

  def publish(user, project)
    source = project.source
    target_root = project.root

    for path in project.asset_paths do
      source_path = File.join(project.root, path)
      target_path = File.join(target_root, path)
      upload source.open(source_path), source.size(source_path), target_path
    end

    for path in %w[home.css]
      upload File.open(path), File.size(path), File.join(target_root, path)
    end

    target_path = File.join(target_root, 'index.html')
    upload project.index_html, project.index_html.size, target_path

    url = "http://#{bucket_name}/#{target_root}/index.html"
    model = Models::Project.first_or_create(:user => user, :name => project.name)
    # FIXME race condition on the timestamp
    model.attributes = { :published_at => Time.now, :public_url => url }
    model.save
    url
  end

  private

  def bucket
    @bucket ||= begin
      s3_connect
      AWS::S3::Bucket.find(bucket_name)
    end
  end

  def s3_connect
    AWS::S3::Base.establish_connection!(
        :access_key_id     => ENV['AMAZON_ACCESS_KEY_ID'],
        :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
      )
  end

  def upload(source, source_length, target_path)
    content_type = source.is_a?(String) && 'text/html'
    object = bucket[target_path]
    if object and object.size == source_length and (!content_type or object.about['content-type'] == content_type)
      puts "Skipping #{target_path} because size and content type match"
      return
    end
    # metadata = { 'x-amz-last-modified' => File.mtime(source_path).to_s }
    puts "Uploading #{target_path}"
    options = {:access => :public_read}
    options[:content_type] = content_type if content_type
    AWS::S3::S3Object.store(target_path, source, bucket_name, options)
  end
end
