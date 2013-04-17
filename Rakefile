require 'rake/clean'
require 'haml'
require './project'
require './file_storage'

def project_dirname
  ENV['PROJECT'] || begin STDERR.puts "PROJECT not set"; exit 1; end
end

def active_project
  Project.new(project_dirname)
end

task :convert do
  project = active_project
  FileUtils::mkdir_p "build"
  open("build/index.html", 'w') do |f| f << project.index_html(:base => "../#{project.project_path}/") end
end

task :upload do
  project = active_project

  AWS::S3::Base.establish_connection!(
      :access_key_id     => ENV['AMAZON_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
    )

  bucket_name = 'assets.matterfront.com'
  bucket = AWS::S3::Bucket.find(bucket_name)

  # storage = FileStorage.new('dbox')
  # p project.asset_paths
  # p project.root
  # exit

  storage_manager = project.storage_manager
  target_root = project.root

  for path in project.asset_paths do
    source_path = File.join(project.root, path)
    target_path = File.join(target_root, path)
    # TODO compare md5
    # puts bucket[target_path].about['md5']
    next if bucket[target_path] and bucket[target_path].size == storage_manager.size(source_path)
    # metadata = { 'x-amz-last-modified' => File.mtime(source_path).to_s }
    puts "Uploading #{path}"
    AWS::S3::S3Object.store(target_path, storage_manager.open(source_path), bucket_name, :access => :public_read)
  end

  for path in %w[home.css]
    # puts "Uploading #{path}"
    # AWS::S3::S3Object.store(File.join(target_root, path), File.open(path), bucket_name, :access => :public_read)
  end

  puts "Uploading index"
  index_object = AWS::S3::S3Object.store(File.join(target_root, 'index.html'), project.index_html, bucket_name, :access => :public_read)
  index_object = bucket[File.join(target_root, 'index.html')]
  p index_object.url
  # p index_object
  # object = bucket.new_object
  # object.value = project.index_html
  # object.key   = File.join(target_root, 'index.html')
  # object.metadata = { 'x-amz-last-modified' => 'storage_manager.mtime(source_path).to_s' }
  # object.store
end
