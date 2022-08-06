require "./spec_helper"

describe Crack::Handler::Static do
  it "delivers static html" do
    request = HTTP::Request.new("GET", "/index.html")
    io, context = create_context(request)
    static = Crack::Handler::Static.instance
    static.public_folder = "spec/sample/public"
    static.call(context)
    context.response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io, decompress: false)
    expect(client_response.body).to eq "<head></head><body>Hello World!</body>\n"
  end

  it "returns Not Found when file doesn't exist" do
    request = HTTP::Request.new("GET", "/not_found.html")
    io, context = create_context(request)
    static = Crack::Handler::Static.instance
    static.public_folder = "spec/sample/public"
    static.call(context)
    context.response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io, decompress: false)
    expect(client_response.body).to eq "404 Not Found\n"
  end

  it "delivers index.html if path ends with /" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    static = Crack::Handler::Static.instance
    static.public_folder = "spec/sample/public"
    static.call(context)
    context.response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io, decompress: false)
    expect(client_response.body).to eq "<head></head><body>Hello World!</body>\n"
  end
end
