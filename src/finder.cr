require "./index"
require "colorize"

module Rf
  class Finder
    def self.walk_dirs(root : Dir) : Array(Index | Int32)
      sublogger = Loggers.for("walk")
      walked_dirs = 0
      sublogger.debug { "visiting #{root}" }
      repos = Index.new
      root.each_subdir do |subdir|
        sublogger.debug { "found #{subdir}" }
        walked_dirs += 1
        if subdir.is_git_repo? || subdir.is_svn_repo?
          sublogger.info { "adding #{subdir}" }
          repos << subdir
        else
          res = walk_dirs(subdir)
          repos.concat res[0].as(Array)
          walked_dirs += res[1].as(Int)
        end
      end
      root.close
      return [repos, walked_dirs]
    end
  end
end
