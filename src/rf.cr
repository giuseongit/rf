require "option_parser"
require "./finder"
require "./ui"
require "keimeno"

module Rf
  VERSION = "0.1.0"

  class App
    CACHE_FILE = ".cache"
    CFG_FILE   = "rf.yml"

    @requested_str : String | Nil
    @logger : Log
    @cache_path : String
    @cfg_dir : String
    @cfg_file : String

    getter cfg : Config

    def initialize
      home = ENV.fetch("HOME", "")
      exit -1 if home == ""

      @cfg_dir = home + "/.config/rf/"
      @cfg_file = @cfg_dir + CFG_FILE

      Loggers.suppress_logs
      Loggers.level_info
      @logger = Loggers.get_logger
      @cache_path = @cfg_dir + CACHE_FILE

      @use_cache = true
      @suppress_output = false

      @wizard = false
      Dir.create_if_not_exists(@cfg_dir)
      if File.exists? @cfg_file
        @cfg = Rf::Config.from_yaml File.read(@cfg_file)
      else
        @cfg = Rf::Config.wizard
        File.write(@cfg_file, @cfg.to_yaml)
        puts "config done. ready to use"
        exit
      end

      @sources_dir = Dir.new(@cfg.repositories_dir)
      @finder = Finder.new @cfg.enabled_vsc

      parse_args
      build_index
      print_result if !@wizard
    end

    def parse_args
      OptionParser.parse do |parser|
        parser.banner = "Usage: rf [search]"
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
      @index = Index.load(@cache_path)

      if @index.nil? || !@use_cache
        @logger.debug { "walking dirs" }
        res = @finder.walk_dirs(@sources_dir)
        @index = res[0].as(Array)
        walked = res[1].as(Int)
        @logger.info { "scanned #{walked} dirs" }
        @index.not_nil!.save(@cache_path)
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
          print Menu.new(selected, @cfg.entries_shown).run
        else
          print selected.join("\n")
        end
      end
    end
  end
end

Rf::App.new
