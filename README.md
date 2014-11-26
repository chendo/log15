# Log15

![obligatory xkcd](http://imgs.xkcd.com/comics/standards.png)

This library was inspired by [inconshreveable/log15](https://github.com/inconshreveable/log15).

`log15` is a structured logger, outputting a message followed by key/value pairs containing more information about that particular line. This is useful if you're piping your logs to something like Kibana and want to make processing them simpler.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'log15'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install log15

## Usage

```ruby
# Create a new log15 logger
logger = Log15::Logger.default
logger.info("Test message", foo: "bar")
```

This will output something like:

```
INFO[11-26|16:27:09] Test message foo="bar"\n"
```

Other log levels are also supported: `debug`, `warn`, and `error`.
