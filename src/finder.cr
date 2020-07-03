require "./index"
require "colorize"

module Rf
  class Finder
    def initialize(@enabled_vscs : SupportedVSC)
    end

    def walk_dirs(root : Dir) : Array(Index | Int32)
      sublogger = Loggers.for("walk")
      walked_dirs = 0
      sublogger.debug { "visiting #{root}" }
      repos = Index.new
      root.each_subdir do |subdir|
        sublogger.debug { "found #{subdir}" }
        walked_dirs += 1
        if (@enabled_vscs.permits_git? && subdir.is_git_repo?) ||
           (@enabled_vscs.permits_svn? && subdir.is_svn_repo?)
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
