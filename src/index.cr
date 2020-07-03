require "./class_extensions"
require "./config"

module Rf
  class Index < Array(Dir)
    def self.load(fpath : String) : Index | Nil
      sublogger = Loggers.for("index")
      if File.exists?(fpath)
        lines = File.read_lines(fpath)
        i = self.new
        skipped = 0
        lines.each do |path|
          begin
            i << Dir.new(path)
          rescue
            sublogger.debug { "#{path} does not exist" }
            skipped += 1
          end
        end
        if skipped > 0
          sublogger.debug { "discarded #{skipped} entries" }
        end
        return i
      else
        sublogger.debug { "cache not found" }
      end
      nil
    end

    def save(fpath : String)
      txt = ""
      each do |repo|
        txt += repo.path + "\n"
      end
      File.write(fpath, txt)
    end
  end
end
