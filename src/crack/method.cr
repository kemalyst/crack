module Crack::Handler
  # The method handler looks for a param["_method"] and overrides the `request.method` with it.
  # This will allow form submits using POST to override the method to match a RESTful backend.
  # DEPENDENT: params handler
  class Method < Base
    property key : String?

    # class method to return a singleton instance of this Controller
    def self.instance
      @@instance ||= new
    end

    def initialize
      @key = "_method"
    end

    def call(context)
      if context.params.has_key? @key
        context.request.method = context.params[@key]
      end
      call_next(context)
    end
  end
end
