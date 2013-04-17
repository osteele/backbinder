require 'rake/clean'
require 'haml'
require './project'
require './file_storage'
require './publisher'

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

task :publish do
  publisher = Publisher.new
  publisher.publish(active_project)
  puts "Open #{publisher.url}"
end
