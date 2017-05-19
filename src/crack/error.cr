module Crack::Handler
  # The Error Handler catches RouteNotFound and returns a 404.  It will
  # response based on the `Accepts` header as JSON or HTML.  It also catches
  # any runtime Exceptions and returns a backtrace in text/plain format.
  class Error < Base
    # class method to return a singleton instance of this Controller
    def self.instance
      @@instance ||= new
    end

    def call(context)
      begin
        call_next(context)
      rescue ex : Exception
        context.response.status_code = 500
        context.response.content_type = "text/plain"
        context.response.print("ERROR: ")
        ex.inspect_with_backtrace(context.response)
      end
    end
  end
end
