require "yaml"
require "berm"

module Rf
  class SupportedVSC < Berm::Flag
    FlagValues = %i(Git Svn)
  end

  struct Config
    include YAML::Serializable

    property repositories_dir : String
    property entries_shown : Int32
    property enabled_vsc : SupportedVSC
    property subrepository_depth : Int32

    private def self.ask_for_input(msg : String, type : Class)
      puts msg
      res = gets.not_nil!

      case
      when type == Dir
        begin
          Dir.new(res)
        rescue
          return ""
        end
        return res
      when type == Bool
        return res == "" || res.downcase[0] == 'y'
      end

      return res
    end

    def self.wizard
      cfg = uninitialized Config

      repositories_dir = ""
      enabled_vsc = SupportedVSC::None

      while repositories_dir == ""
        repositories_dir = ask_for_input("What is the absolute path of your repositories directory?", Dir).as(String)
      end

      if ask_for_input("Whould you like me to look for git repositories? [Y/n]", Bool)
        enabled_vsc = enabled_vsc | SupportedVSC::Git
      end

      if ask_for_input("Whould you like me to look for svn repositories? [Y/n]", Bool)
        enabled_vsc = enabled_vsc | SupportedVSC::Svn
      end

      cfg.repositories_dir = repositories_dir
      cfg.enabled_vsc = enabled_vsc
      cfg.entries_shown = 5
      cfg.subrepository_depth = 1

      return cfg
    end
  end
end
