require 'redcarpet'
require 'safe_yaml'

class Project
  attr_reader :root, :name
  attr_accessor :source

  def initialize(dirname)
    @root = dirname
    @name = dirname
  end

  def config
    config_path = File.join(root, "project.yml")
    @config ||= source.exists?(config_path) ? source.open(config_path) { |file| YAML::load(file, :safe => true) } : {}
  end

  def sources
    @sources ||= (source.find("#{root}/**/*.markdown") + source.find("#{root}/**/*.md")).sort
  end

  def asset_paths
    files = []
    %w[png gif jpg jpeg].each do |suffix|
      files += source.find("#{root}/**/*.#{suffix}")
    end
    return files.map { |pathname| Pathname.new(pathname).relative_path_from(Pathname.new(self.root)).to_s }
  end

  def articles
    @articles ||= sources.map do |file|
      # puts File.basename(file)
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::XHTML, :autolink => true, :space_after_headers => true, :no_images => false)
      html = markdown.render(source.read(file))
      title = html[%r|<h1>(.*?)</h1>|, 1]
      image = html[%r|<img\b[^>]*\bsrc="([^>"]+).*?>|, 1]
      image = %Q|<img src="#{image}" max-width="50px"/>| if image
      para = html[%r|<p>(.*?)</p>|]
      "<h2>#{title}</h2>" + (image || para)
    end
  end

  def title
    config['title'] || root
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
