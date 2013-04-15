require 'rake/clean'
require 'redcarpet'
require 'haml'
require 'safe_yaml'

task :convert do
  project_dirname = ENV['PROJECT'] || 'ProGit'
  project_path = "dbox/#{project_dirname}"

  config_path = File.join(project_path, "project.yml")
  config = File.exists?(config_path) ? YAML::load(open(config_path), :safe => true) : {}

  articles = Dir["#{project_path}/**/*.markdown"].map do |file|
    puts File.basename(file)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::XHTML, :autolink => true, :space_after_headers => true, :no_images => false)
    html = markdown.render(open(file).read)
    title = html[%r|<h1>(.*?)</h1>|, 1]
    image = html[%r|<img\b[^>]*\bsrc="([^>"]+).*?>|, 1]
    image = %Q|<img src="#{image}" max-width="50px"/>| if image
    para = html[%r|<p>(.*?)</p>|]
    "<h2>#{title}</h2>" + (image || para)
  end

  template = File.read('index.haml')
  title = config['title'] || project_dirname
  base = "../#{project_path}/"
  haml_engine = Haml::Engine.new(template)
  output = haml_engine.render(binding)
  FileUtils::mkdir_p "build"
  open("build/index.html", 'w') do |f| f << output end
end
