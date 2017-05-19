require "./spec_helper"

describe Crack::Handler::Error do
  it "handles all exceptions" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    error = Crack::Handler::Error.instance
    error.next = ->(c : HTTP::Server::Context) { raise "Oh no!" }
    error.call(context)
    expect(context.response.status_code).to eq 500
  end
end
