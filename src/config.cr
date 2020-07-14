require "yaml"
require "berm"

module Rf
  class SupportedVSC < Berm::Flag
    FlagValues = %i(Git Svn)

    def to_yaml(yaml : YAML::Nodes::Builder)
      enabled = [] of PermValues
      PermValues.each do |val|
        enabled << val if value & val.value == val.value
      end
      enabled << PermValues::None if enabled.size == 0

      yaml.scalar enabled.join("|").downcase
    end

    def from_string(string : String) : UInt32
      flags = string.split("|")
      res = 0_u32

      flags.each do |flag|
        PermValues.each do |val|
          res += val.to_u32 if val.to_s.downcase == flag
        end
      end

      return res
    end

    def initialize(ctx : YAML::ParseContext, node : YAML::Nodes::Node)
      value = 0_u32
      if node.is_a?(YAML::Nodes::Scalar)
        value = from_string(node.value)
      end
      @value = value
    end
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
