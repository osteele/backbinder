require 'rake/clean'
require 'haml'
require './project'
require './file_source'
require './dropbox_source'
require './publisher'

def project_dirname
  ENV['PROJECT'] || begin STDERR.puts "PROJECT not set"; exit 1; end
end

def active_project
  project = Project.new(project_dirname)
  project.source = FileSource.new('dbox')
  project.source = DropboxSource.new if ENV['SOURCE'] =~ /^dropbox$/i
  project
end

task :convert do
  project = active_project
  FileUtils::mkdir_p "build"
  open("build/index.html", 'w') do |f| f << project.index_html(:base => "../#{project.project_path}/") end
end

task :publish do
  project = active_project
  publisher = Publisher.new
  publisher.publish(project)
  puts "Open #{publisher.url}"
end
