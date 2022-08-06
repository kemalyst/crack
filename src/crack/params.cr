require "json"

# Open Context and add `params` and `files` hash.
class HTTP::Server::Context
  # clear the params.
  def clear_params
    @params = HTTP::Params.new({} of String => Array(String))
  end

  # params hold all the parameters that may be passed in a request.  The
  # parameters come from either the url or the body via json or form posts.
  def params
    @params ||= HTTP::Params.new({} of String => Array(String))
  end

  # clear the files
  def clear_files
    @files = {} of String => FileUpload
  end

  # files hold all the files that are uploaded as multipart form.
  def files
    @files ||= {} of String => FileUpload
  end
end

struct FileUpload
  getter tmpfile : File
  getter filename : String?
  getter headers : HTTP::Headers
  getter creation_time : Time?
  getter modification_time : Time?
  getter read_time : Time?
  getter size : UInt64?

  def initialize(upload)
    @tmpfile = File.tempfile(filename)
    ::File.open(@tmpfile.path, "w") do |file|
      IO.copy(upload.body, file)
    end
    @filename = upload.filename
    @headers = upload.headers
    @creation_time = upload.creation_time
    @modification_time = upload.modification_time
    @read_time = upload.read_time
    @size = upload.size
  end
end

module Crack::Handler
  # The Params handler will parse parameters from a URL, a form post or a JSON
  # post and provide them in the context params hash.  This unifies access to
  # parameters into one place to simplify access to them.
  # Note: other params from the router will be handled in the router handler
  # instead of here.  This removes a dependency on the router in case it is
  # replaced or not needed.
  class Params < Base
    URL_ENCODED_FORM = "application/x-www-form-urlencoded"
    MULTIPART_FORM   = "multipart/form-data"
    APPLICATION_JSON = "application/json"

    # class method to return a singleton instance of this Controller
    def self.instance
      @@instance ||= new
    end

    def call(context)
      context.clear_params
      parse(context)
      call_next(context)
    end

    def parse(context)
      parse_query(context)
      if content_type = context.request.headers["Content-Type"]?
        parse_multipart(context) if content_type.try(&.starts_with?(MULTIPART_FORM))
        parse_body(context) if content_type.try(&.starts_with?(URL_ENCODED_FORM))
        parse_json(context) if content_type == APPLICATION_JSON
      end
    end

    def parse_query(context)
      parse_part(context, context.request.query)
    end

    def parse_body(context)
      parse_part(context, context.request.body)
    end

    def parse_multipart(context)
      HTTP::FormData.parse(context.request) do |upload|
        next unless upload
        filename = upload.filename
        if !filename.nil?
          context.files[upload.name] = FileUpload.new(upload: upload)
        else
          context.params.add(upload.name, upload.body.gets_to_end)
        end
      end
    end

    def parse_json(context)
      if body = context.request.body.not_nil!.gets_to_end
        if body.size > 2
          case json = JSON.parse(body).raw
          when Hash
            json.each do |key, value|
              context.params[key.as(String)] = value.to_s
            end
          when Array
            context.params["_json"] = json.to_s
          end
        end
      end
    end

    private def parse_part(context, part)
      values = case part
               when IO
                 part.gets_to_end
               when String
                 part.to_s
               else
                 ""
               end

      HTTP::Params.parse(values) do |key, value|
        context.params.add(key, value)
      end
    end
  end
end
