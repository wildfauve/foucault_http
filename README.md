# Foucault

Foucault plays with a functional interface for wrapping network service calls.  Not exactly very functional, as the network is a touch mutating.  However, its an attempt to leverage a little of that Ruby lambda magic to describe another method of wrapping classes.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'foucault_http'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install foucault_http

## Usage

`FoucaultHttp::Net` contains the main functions for HTTP wrappers.  All the wrappers are defined as curried functions.  So it is OK to partially apply in the argument order.

## Configuration

You provide configuration through the object

```ruby
FoucaultHttp::Configuration.configure do |config|
  config.logger                = SomeLogger         # Any class that responds to the log level methods with a single param
                                                    # (a string or hash if you're using a structured log format)
  config.network_log_formatter = SomeLogFormatter   # A class which inherits from Faraday::Logging::Formatter
  config.logging_level         = :info
end
```

### HTTP

#### Post

The `post` fn takes the following arguments in this order:
+ `correlation`. A hash of name value pairs to be logged.  Default is `{}`
+ `service`.  The http host.  It will be combined with the `resource` to form a url.
+ `resource`.  The resource making up the URL.
+ `hdrs`.  A hash of HTTP headers.
+ `enc`.  The default encoding for the body.
+ `body_fn`.  A fn with which to serialise the body.  The functions are available in the `FoucaultHttp::Net` class.  They are:
  + `json_body_fn`.  Converts the body to JSON.
+ `body`.  The body to send to the service/resource

Example:  This shows the use of partial application.  You can just as easily combine the arguments into a single argument list.

```ruby
FoucaultHttp::Net.post.({}, "http://api.example.com").("/resource").(nil).(nil).(FoucaultHttp::Net.json_body_fn).({message: "some message"})
```

#### Get

The `get` fn takes the following arguments in this order:
+ `correlation`
+ `service`
+ `resource`
+ `hdrs`
+ `enc`
+ `query`

For example:

```ruby
FoucaultHttp::Net.get.({}, "http://api.example.com", "/resource").({authorization: "uid:pwd"}).(:url_encoded).({param1: 1})
```

#### Helper Functions

1. Basic Authentication Header Encoder.  Creates an `Authorization` header appropriately encoded for basic auth.

```ruby
FoucaultHttp::Net.basic_auth_header.("client_id").("secret")
```

2. Header builder.  Takes any number of individual arguments which evaluate to Hashes and combines them into a single hash.  Not really that interesting, you can always throw in your own `merge`

```ruby
FoucaultHttp::Net.header_builder.(FoucaultHttp::Net.basic_auth_header.("userid", "password"), {content_type: "application/json"})
```

### Return Object

All network functions return a `FoucaultHttp::NetResponseValue` wrapped in a `Result` monad.

So, for example, you might test and extract the results as follows:

```ruby
result = FoucaultHttp::Net.post.("http://api.example.com").("/resource").({}).(nil).(FoucaultHttp::Net.json_body_fn).({message: "some message"})

result.success?   # or result.failure?
result.value_or.status   # => :ok
result.value_or.body     # => some returned structure.
```

The `FoucaultHttp::NetResponseValue` generalises the network states as follows:

+ `:ok`; its all good.
+ `:fail`; the network request happened, but failed for some reason (such as resource not found)
+ `:unauthorised`; no access to the service.
+ `:system_failure`; a failures before the service; such as network problems.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

To update the gem on RubyGems:

+ Update the version
+ `gem build foucault_http.gemspec`
+ `gem push foucault_http-v.v.v.gem`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wildfauve/foucault_http. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Foucault project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/foucault/blob/master/CODE_OF_CONDUCT.md).
