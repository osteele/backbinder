require 'rake/clean'
require 'haml'
require './project'

project_dirname = ENV['PROJECT'] || 'ProGit'

task :convert do
  project = Project.new(project_dirname)
  FileUtils::mkdir_p "build"
  open("build/index.html", 'w') do |f| f << project.index_html(:base => "../#{project.project_path}/") end
end

task :upload do
  project = Project.new(project_dirname)
  AWS::S3::Base.establish_connection!(
      :access_key_id     => ENV['AMAZON_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
    )

  bucket_name = 'assets.matterfront.com'
  bucket = AWS::S3::Bucket.find(bucket_name)

  for path in project.assets
    source_path = File.expand_path(path, project.project_path)
    target_path = File.join(project.dirname, path)
    next if bucket[target_path] and bucket[target_path].size == File.size(source_path)
    # metadata = { 'x-amz-last-modified' => File.mtime(source_path).to_s }
    puts "Uploading #{path}"
    AWS::S3::S3Object.store(target_path, open(source_path), bucket_name, :access => :public_read)
  end

  AWS::S3::S3Object.store(File.join(project.dirname, "index.html"), project.index_html, bucket_name, :access => :public_read)
  AWS::S3::S3Object.store(File.join(project.dirname, "home.css"), File.open("home.css"), bucket_name, :access => :public_read)
end
