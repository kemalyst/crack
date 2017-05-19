require "./spec_helper"

describe Crack::Handler::Logger do
  it "logs a request/response" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)

    handler = Crack::Handler::Block.new(->(c : HTTP::Server::Context) { "Hello World!" })
    loghandler = Crack::Handler::Logger.instance
    loghandler.next = handler
    loghandler.call(context)
  end
end
