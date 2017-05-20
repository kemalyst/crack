# Crack Middleware

Crack provides a set of common `HTTP::Handlers` that are similar to Rack Middleware.

Each handler provides changes needed to the `HTTP::Server::Context` and the ability to configure
the handler using a block that is yields to self for setting any properties.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  crack:
    github: kemalyst/crack
```

## Usage

Add the handler to your HTTP::Server implementation:

```crystal
require "crack"
require "http/server"

Crack::Handler::Logger.instance.config do |config|
  config.logger = Logger.new(STDOUT)
end

Crack::Handler::Static.instance.config do |config|
  config.public_folder = "./public"
  config.default_file = "index.html"
end

HTTP::Server.new("127.0.0.1", 8080, [
  Crack::Handler::Error.instance,
  Crack::Handler::Logger.instance,
  Crack::Handler::Static.instance,
]).listen
```

You can add these to `Kemal` or any other framework that support `HTTP::Handlers` in their stack.

## Development

If you want to add a handler to this library, please follow the pattern provided:
  - Provide a singleton pattern with the `self.instance` method to instantiate
  - Provide a `self.config()` and `config()` method that yields self to a block to set any properties needed
  - If your handler requires logging, provide a `property logger : Logger` that can be configured in the config methods.  This should use the `Logger` base from the stdlib
  - If your handler requires modifying the `HTTP::Server::Context`, do so at the top of the handler so its clear what additions are being made
  - Document the purpose of the handler.  If there are other handlers that perform a similar task, provide the reason one might chose yours over the other
  - Provide specs that cover the main functionality of your handler.

## Contributing

1. Fork it ( https://github.com/kemalyst/crack/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [drujensen](https://github.com/drujensen) Dru Jensen - creator, maintainer
- [bigtunacan](https://github.com/bigtunacan) Joiey Seeley - contributor
