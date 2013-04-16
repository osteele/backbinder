require 'redcarpet'
require 'safe_yaml'
require 'aws/s3'

class Project
  attr_reader :dirname, :project_path

  def initialize(dirname)
    @dirname = dirname
    @project_path = "dbox/#{dirname}"
  end

  def config
    config_path = File.join(project_path, "project.yml")
    @config ||= File.exists?(config_path) ? YAML::load(open(config_path), :safe => true) : {}
  end

  def sources
    @sources ||= (Dir["#{project_path}/**/*.markdown"] + Dir["#{project_path}/**/*.md"]).sort
  end

  def assets
    files = []
    %w[png gif jpg jpeg].each do |suffix|
      files += Dir["#{project_path}/**/*.#{suffix}"]
    end
    return files.map { |pathname| Pathname.new(pathname).relative_path_from(Pathname.new(self.project_path)).to_s }
  end

  def articles
    @articles ||= sources.map do |file|
      puts File.basename(file)
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::XHTML, :autolink => true, :space_after_headers => true, :no_images => false)
      html = markdown.render(open(file).read)
      title = html[%r|<h1>(.*?)</h1>|, 1]
      image = html[%r|<img\b[^>]*\bsrc="([^>"]+).*?>|, 1]
      image = %Q|<img src="#{image}" max-width="50px"/>| if image
      para = html[%r|<p>(.*?)</p>|]
      "<h2>#{title}</h2>" + (image || para)
    end
  end

  def title
    config['title'] || dirname
  end

  def index_html(options={})
    base = options[:base]
    schemac = base ? "http:" : ""
    css_path = base ? "../../" : ""
    title = self.title
    articles = self.articles

    template = File.read('index.haml')
    haml_engine = Haml::Engine.new(template)
    return haml_engine.render(binding)
  end
end
