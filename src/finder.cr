require "./index"
require "colorize"

module Rf
  class Finder
    def initialize(@enabled_vscs : SupportedVSC, @max_subrepo_depth : Int32)
    end

    def walk_dirs(root : Dir) : Array(Index | Int32)
      internal_walk_dirs(root)
    end

    private def internal_walk_dirs(root : Dir, depth : Int32 = 1) : Array(Index | Int32)
      sublogger = Loggers.for("walk")
      walked_dirs = 0
      sublogger.debug { "visiting #{root}" }
      repos = Index.new
      root.each_subdir do |subdir|
        sublogger.debug { "found #{subdir}" }
        walked_dirs += 1
        repo_depth = depth
        if (@enabled_vscs.permits_git? && subdir.is_git_repo?) ||
           (@enabled_vscs.permits_svn? && subdir.is_svn_repo?)
          sublogger.info { "adding #{subdir}" }
          repos << subdir
          if depth >= @max_subrepo_depth
            next
          end
          repo_depth += 1
        end
        res = internal_walk_dirs(subdir, repo_depth)
        repos.concat res[0].as(Array)
        walked_dirs += res[1].as(Int)
      end
      root.close
      return [repos, walked_dirs]
    end
  end
end
