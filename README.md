# boa

![main workflow](https://github.com/gscho/boa-config/actions/workflows/main.yml/badge.svg)

Boa is a pluggable, zero-dependency, ruby implementation of the [Viper](https://github.com/spf13/viper) configuration library for Go.

For examples check out the `examples/` folder.

Natively boa supports:

- JSON
- YAML

Boa also supports these configuration types via plugins:

- TOML

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add boa-config

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install boa-config

## Usage

Much like the Golang implementation, boa is meant to be used like a singleton class. By default, the boa singleton class is accessible via a global variable named `$boa`.

### Setting Defaults

Many times we need to set defaults for config values which can be done using `set_default`.

```ruby
require "boa"

$boa.set_default("foo", "bar")
$boa.get("foo") #  => "bar"
```

### Reading Config

Boa supports reading in configuration files from the local filesystem or directly from a variable.

```ruby
require "boa"

# Read a config file from disk at "/etc/my_app/my_config.json" or "./my_config.json" in that order.
$boa.set_config_name("my_config")
$boa.set_config_type("json")
$boa.add_config_path("/etc/my_app", ".")
$boa.read_in_config

# Read config from a variab;e
config = <<-YAML
db:
  user: postgres
  port: 5432
YAML
$boa.read_config(config)
$boa.get("db.user") #  => "postgres"
```

### Reading Environment Variables

Boa can bind configuration values to environment variables and automatically check environment variables before reading configuration from a file.

```ruby
require "boa"

# Bind to environment variables using a prefix
ENV["MY_APP_USER"] = "bob_vance" # Usually done outside the application
$boa.set_env_prefix("MY_APP")
$boa.bind_env("USER") # automatically appends the "MY_APP" prefix.
# lookup is case insensitive
$boa.get("user") #  => "bob_vance"
$boa.get("USER") #  => "bob_vance"

# Automatically check environment variables
ENV["PORT"] = 9292
config = <<-YAML
port: 4567
host: localhost
YAML
$boa.read_config(config)
$boa.automatic_env
$boa.get("host") #  => "localhost"
$boa.get("port") #  => 9292
```

### Writing Config Files

### Adding Plugins

### Writing Plugins

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/Boa. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/Boa/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Boa project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/Boa/blob/main/CODE_OF_CONDUCT.md).
