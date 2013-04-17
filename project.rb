require 'redcarpet'
require 'safe_yaml'
require 'aws/s3'
require './file_storage'

class Project
  attr_reader :root
  attr_accessor :storage_manager

  def initialize(dirname)
    @root = dirname
    @storage_manager = FileStorage.new('dbox')
  end

  def config
    config_path = File.join(root, "project.yml")
    @config ||= storage_manager.exists?(config_path) ? YAML::load(storage_manager.open(config_path), :safe => true) : {}
  end

  def sources
    @sources ||= (storage_manager.find("#{root}/**/*.markdown") + storage_manager.find("#{root}/**/*.md")).sort
  end

  def asset_paths
    files = []
    %w[png gif jpg jpeg].each do |suffix|
      files += storage_manager.find("#{root}/**/*.#{suffix}")
    end
    return files.map { |pathname| Pathname.new(pathname).relative_path_from(Pathname.new(self.root)).to_s }
  end

  def articles
    @articles ||= sources.map do |file|
      # puts File.basename(file)
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::XHTML, :autolink => true, :space_after_headers => true, :no_images => false)
      html = markdown.render(storage_manager.open(file).read)
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
