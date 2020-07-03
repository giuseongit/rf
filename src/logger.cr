require "log"

struct ColorizedFormatter < Log::StaticFormatter
  RESET = "\033[0;0m"
  RED   = "\033[0;31m"
  GREEN = "\033[0;32m"
  CYAN  = "\033[0;96m"

  def run
    case @entry.severity
    when Log::Severity::Info
      color = GREEN
    when Log::Severity::Debug
      color = CYAN
    else
      color = RESET
    end
    string color
    timestamp
    string " "
    severity
    string " - "
    source(after: ": ")
    message
    # Message might be colorized, so we reset the right color
    string color
    data(before: " -- ")
    context(before: " -- ")
    exception
    string RESET
  end
end

module Rf
  class Loggers
    @@instance = ::Log.for("main")

    def self.get_logger
      @@instance
    end

    def self.log_to_stdout
      log_to_stream
    end

    def self.suppress_logs
      log_to_stream nil
    end

    def self.level_info
      set_logging_level Log::Severity::Info
    end

    def self.level_debug
      set_logging_level Log::Severity::Debug
    end

    def self.for(facility : String)
      sublogger = @@instance.for(facility)
      configure_sublogger(sublogger)
    end

    private def self.set_logging_level(sev : Log::Severity)
      @@instance.level = sev
    end

    private def self.log_to_stream(stream = STDERR)
      if !stream.nil?
        @@instance.backend = Log::IOBackend.new(stream, formatter: ColorizedFormatter)
      else
        @@instance.backend = nil
      end
    end

    private def self.configure_sublogger(sublogger : Log)
      sublogger.backend = @@instance.backend
      sublogger.level = @@instance.level
      sublogger
    end
  end
end
