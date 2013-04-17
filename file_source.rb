class FileSource
  attr_reader :root

  def initialize(root)
    @root = root
  end

  def exists?(path)
    File.exists?(resolve(path))
  end

  def find(pattern)
    Dir[File.join(root, pattern)].map { |path| Pathname.new(path).relative_path_from(Pathname.new(root)).to_s }
  end

  def open(path, &block)
    File.open(resolve(path), &block)
  end

  def read(path)
    File.read(resolve(path))
  end

  def size(path)
    File.size(resolve(path))
  end

  private

  def resolve(path)
    File.join(root, path)
  end
end
