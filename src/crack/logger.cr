require "log"

module Crack::Handler
  # The Logger handler logs every request/response to the provided logger.
  # The logger can be configured as STDIN/STDOUT or as a log file.  A custom
  # logger can be configured and passed in as well.
  class Logger < Base
    def self.instance
      @@instance ||= new
    end

    def initialize
    end

    def call(context)
      time = Time.local
      call_next(context)

      status_code = context.response.status_code
      method = context.request.method
      resource = context.request.resource
      elapsed = elapsed_text(Time.local - time)

      output_message = "#{status_code} | #{method} #{resource} | #{elapsed}"

      Log.info { output_message }

      context
    end

    private def elapsed_text(elapsed)
      minutes = elapsed.total_minutes
      return "#{minutes.round(2)}m" if minutes >= 1

      seconds = elapsed.total_seconds
      return "#{seconds.round(2)}s" if seconds >= 1

      millis = elapsed.total_milliseconds
      return "#{millis.round(2)}ms" if millis >= 1

      "#{(millis * 1000).round(2)}µs"
    end
  end
end
