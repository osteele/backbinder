require 'uri'

class Publisher
  attr_reader :bucket_name

  def initialize
    @bucket_name = 'assets.matterfront.com'
  end

  def publish(project)
    storage_manager = project.storage_manager
    target_root = project.root

    for path in project.asset_paths do
      source_path = File.join(project.root, path)
      target_path = File.join(target_root, path)
      upload storage_manager.open(source_path), storage_manager.size(source_path), target_path
    end

    for path in %w[home.css]
      upload File.open(path), File.size(path), File.join(target_root, path)
    end

    target_path = File.join(target_root, 'index.html')
    upload project.index_html, project.index_html.size, target_path
    @index_object = bucket[target_path]
  end

  def url
    uri = URI(@index_object.url(:expires => nil))
    uri.query = nil
    uri.to_s
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
    # TODO compare md5
    # puts bucket[target_path].about['md5']
    object = bucket[target_path]
    if object and object.size == source_length
      puts "Skipping #{target_path} because size matches"
      return
    end
    # metadata = { 'x-amz-last-modified' => File.mtime(source_path).to_s }
    puts "Uploading #{target_path}"
    AWS::S3::S3Object.store(target_path, source, bucket_name, :access => :public_read)
  end
end
