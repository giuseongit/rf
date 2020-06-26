require "option_parser"
require "./finder"
require "./ui"
require "keimeno"

# TODO: Write documentation for `Rf`
module Rf
  VERSION = "0.1.0"

  class App
    @requested_str : String | Nil
    @logger : Log

    def initialize(@cfg_dir : String, sources_dir : String)
      Dir.create_if_not_exists(@cfg_dir)
      @sources_dir = Dir.new(sources_dir)
      Loggers.suppress_logs
      @logger = Loggers.get_logger
    end

    def parse_args
      Loggers.level_info
      @use_cache = true
      @suppress_output = false
      OptionParser.parse do |parser|
        parser.banner = "Usage: find-repos [search]"
        parser.on("-i", "--ignore-cache", "ignore and rebuild cache") { @use_cache = false }
        parser.on("-r", "--rebuild-cache", "rebuild cache without output") { @use_cache = false; @suppress_output = true }
        parser.on("-l", "--logging", "enable logging") { Loggers.log_to_stdout }
        parser.on("-v", "--verbose", "verbose mode") { Loggers.level_debug }
        parser.on("-h", "--help", "Show this help") { puts parser; exit }
      end

      if ARGV.size > 0
        @requested_str = ARGV[0]
      end
    end

    def build_index
      @index = Index.load(@cfg_dir)

      if @index.nil? || !@use_cache
        @logger.debug { "walking dirs" }
        res = Finder.walk_dirs(@sources_dir)
        @index = res[0].as(Array)
        walked = res[1].as(Int)
        @logger.info { "scanned #{walked} dirs" }
        @index.not_nil!.save(@cfg_dir)
      else
        @logger.debug { "using cache" }
      end

      @logger.info { "found #{@index.not_nil!.size} repos" }
    end

    def print_result
      selected = [] of Dir
      if !@suppress_output
        if @requested_str
          @logger.debug { "requested repo = #{@requested_str.not_nil!}" }
          @index.not_nil!.each do |dir|
            if dir.path.downcase.includes?(@requested_str.not_nil!.downcase)
              selected << dir
            end
          end
        else
          @index.not_nil!.each do |dir|
            selected << dir
          end
        end
        if selected.size > 1
          print Menu.new(selected).run
        else
          print selected.join("\n")
        end
      end
    end

    def run
      parse_args
      build_index
      print_result
    end
  end
end

home = ENV.fetch("HOME", "/home/giuse")
config_dir = home + "/.config/find-repos"
repos_dir = home + "/repos"

Rf::App.new(config_dir, repos_dir).run
