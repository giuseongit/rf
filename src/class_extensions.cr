require "./logger"

module DirRepositoryDiscovery
  def is_git_repo? : Bool
    Dir.exists?(path + "/.git")
  end

  def is_svn_repo? : Bool
    Dir.exists?(path + "/.svn")
  end
end

class Dir
  def self.create_if_not_exists(path)
    sublogger = Rf::Loggers.for("dir")
    if !Dir.exists? path
      sublogger.debug { "creating dir(s) #{path}" }
      Dir.mkdir_p path
    end
  end

  def to_s(io : IO)
    io << path
  end

  def each_subdir
    each_child do |entry|
      dirpath = path + "/" + entry
      if Dir.exists?(dirpath)
        yield Dir.new(dirpath)
      end
    end
  end

  include DirRepositoryDiscovery
end
