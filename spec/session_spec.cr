require "./spec_helper"

describe Crack::Handler::Session do
  it "sets a cookie" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    session = Crack::Handler::Session.instance
    session.call(context)
    expect(context.response.headers.has_key?("set-cookie")).to be_true
  end

  it "encodes the session data" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    session = Crack::Handler::Session.instance
    context.session["authorized"] = "true"
    session.call(context)
    cookie = context.response.headers["set-cookie"]
    expect(cookie).to eq "crack.session=3e7ed013efb3fde48e16687d048498842fa84df4--eyJhdXRob3JpemVkIjoidHJ1ZSJ9"
  end

  it "uses a secret" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    session = Crack::Handler::Session.instance
    session.secret = "0c04a88341ec9ffd2794a0d35c9d58109d8fff32dfc48194c2a2a8fc62091190920436d58de598ca9b44dd20e40b1ab431f6dcaa40b13642b69d0edff73d7374"
    context.session["authorized"] = "true"
    session.call(context)
    cookie = context.response.headers["set-cookie"]
    expect(cookie).to eq "crack.session=2b4e0cbc9209bf2b432fa669a7219776d6066858--eyJhdXRob3JpemVkIjoidHJ1ZSJ9"
  end

  context "context" do
    it "holds session hash" do
      request = HTTP::Request.new("GET", "/")
      io, context = create_context(request)
      context.session["test"] = "test"
      expect(context.session.size).to eq 1
    end

    it "clears session hash" do
      request = HTTP::Request.new("GET", "/")
      io, context = create_context(request)
      context.session["test"] = "test"
      context.clear_session
      expect(context.session.size).to eq 0
    end
  end
end
