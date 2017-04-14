# Application_Ruby Cookbook

[![Build Status](https://img.shields.io/travis/poise/application_ruby.svg)](https://travis-ci.org/poise/application_ruby)
[![Gem Version](https://img.shields.io/gem/v/poise-application-ruby.svg)](https://rubygems.org/gems/poise-application-ruby)
[![Cookbook Version](https://img.shields.io/cookbook/v/application_ruby.svg)](https://supermarket.chef.io/cookbooks/application_ruby)
[![Coverage](https://img.shields.io/codecov/c/github/poise/application_ruby.svg)](https://codecov.io/github/poise/application_ruby)
[![Gemnasium](https://img.shields.io/gemnasium/poise/application_ruby.svg)](https://gemnasium.com/poise/application_ruby)
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

A [Chef](https://www.chef.io/) cookbook to deploy Ruby applications.

## Quick Start

To deploy a Rails application from git:

```ruby
application '/srv/myapp' do
  git 'https://github.com/example/myapp.git'
  bundle_install do
    deployment true
    without %w{development test}
  end
  rails do
    database 'sqlite3:///db.sqlite3'
    secret_token 'd78fe08df56c9'
    migrate true
  end
  unicorn do
    port 8000
  end
end
```

## Requirements

Chef 12.1 or newer is required.

## Resources

### `application_bundle_install`

The `application_bundle_install` resource installs gems using Bundler for a
deployment.

```ruby
application '/srv/myapp' do
  bundle_install do
    deployment true
    without %w{development test}
  end
end
```

All actions and properties are the same as the [`bundle_install` resource](https://github.com/poise/poise-ruby#bundle_install).

### `application_puma`

The `application_puma` resource creates a service for `puma`.

```ruby
application '/srv/myapp' do
  puma do
    port 8000
  end
end
```

#### Actions

* `:enable` – Create, enable and start the service. *(default)*
* `:disable` – Stop, disable, and destroy the service.
* `:start` – Start the service.
* `:stop` – Stop the service.
* `:restart` – Stop and then start the service.
* `:reload` – Send the configured reload signal to the service.

#### Properties

* `path` – Base path for the application. *(name attribute)*
* `port` – Port to listen on. *(default: 80)*
* `service_name` – Name of the service to create. *(default: auto-detect)*
* `user` – User to run the service as. *(default: application owner)*

### `application_rackup`

The `application_rackup` resource creates a service for `rackup`.

```ruby
application '/srv/myapp' do
  rackup do
    port 8000
  end
end
```

#### Actions

* `:enable` – Create, enable and start the service. *(default)*
* `:disable` – Stop, disable, and destroy the service.
* `:start` – Start the service.
* `:stop` – Stop the service.
* `:restart` – Stop and then start the service.
* `:reload` – Send the configured reload signal to the service.

#### Properties

* `path` – Base path for the application. *(name attribute)*
* `port` – Port to listen on. *(default: 80)*
* `service_name` – Name of the service to create. *(default: auto-detect)*
# `user` – User to run the service as. *(default: application owner)*

### `application_rails`

The `application_rails` resource

```ruby
application '/srv/myapp' do
  rails do
    database 'sqlite3:///db.sqlite3'
    secret_token 'd78fe08df56c9'
    migrate true
  end
end
```

#### Actions

* `:deploy` – Create config files and run required deployments steps. *(default)*

#### Properties

* `path` – Base path for the application. *(name attribute)*
* `app_module` – Top-level application module. Only needed for the :initializer
  style of secret token configuration. *(default: auto-detect)*
* `database` – Database settings for Rails. See [the database section
  below](#database-parameters) for more information. *(option collector)*
* `migrate` – Run database migrations. *(default: false)*
* `precompile_assets` – Run `rake assets:precompile`. *(default: auto-detect)()
* `rails_env` – Rails environment name. *(default: node.chef_environment)*
* `secret_token` – Secret token for Rails session verification et al.
* `secrets_mode` – Secrets configuration mode. Set to `:yaml` to generate a
  Rails 4.2 secrets.yml. Set to `:initializer` to update
  `config/initializers/secret_token.rb`. *(default: auto-detect)*

**NOTE:** At this time `secrets_mode :initializer` is not implemented.

#### Database Parameters

The database parameters can be set in three ways: URL, hash, and block.

If you have a single URL for the parameters, you can pass it directly to
`database`:

```ruby
rails do
  database 'mysql2://myuser@dbhost/myapp'
end
```

Passing a single URL will also set the `$DATABASE_URL` environment variable
automatically for compatibility with Heroku-based applications.

As with other option collector resources, you can pass individual settings as
either a hash or block:

```ruby
rails do
  database do
    adapter 'mysql2'
    username 'myuser'
    host 'dbhost'
    database 'myapp'
  end
end

rails do
  database({
    adapter: 'mysql2',
    username: 'myuser',
    host: 'dbhost',
    database: 'myapp',
  })
end
```

### `application_ruby`

The `application_ruby` resource installs a Ruby runtime for the deployment.

```ruby
application '/srv/myapp' do
  ruby '2.2'
end
```

All actions and properties are the same as the [`ruby_runtime` resource](https://github.com/poise/poise-ruby#ruby_runtime).

### `application_ruby_gem`

The `application_ruby_gem` resource installs Ruby gems for the deployment.

```ruby
application '/srv/myapp' do
  ruby_gem 'rake'
end
```

All actions and properties are the same as the [`ruby_gem` resource](https://github.com/poise/poise-ruby#ruby_gem).

### `application_ruby_execute`

The `application_ruby_execute` resource runs Ruby commands for the deployment.

```ruby
application '/srv/myapp' do
  ruby_execute 'rake'
end
```

All actions and properties are the same as the [`ruby_execute` resource](https://github.com/poise/poise-ruby#ruby_execute),
except that the `cwd`, `environment`, `group`, and `user` properties default to
the application-level data if not specified.

### `application_thin`

The `application_thin` resource creates a service for `thin`.

```ruby
application '/srv/myapp' do
  thin do
    port 8000
  end
end
```

#### Actions

* `:enable` – Create, enable and start the service. *(default)*
* `:disable` – Stop, disable, and destroy the service.
* `:start` – Start the service.
* `:stop` – Stop the service.
* `:restart` – Stop and then start the service.
* `:reload` – Send the configured reload signal to the service.

#### Properties

* `path` – Base path for the application. *(name attribute)*
* `config_path` – Path to a Thin configuration file.
* `port` – Port to listen on. *(default: 80)*
* `service_name` – Name of the service to create. *(default: auto-detect)*
* `user` – User to run the service as. *(default: application owner)*

### `application_unicorn`

The `application_unicorn` resource creates a service for `unicorn`.

```ruby
application '/srv/myapp' do
  unicorn do
    port 8000
  end
end
```

#### Actions

* `:enable` – Create, enable and start the service. *(default)*
* `:disable` – Stop, disable, and destroy the service.
* `:start` – Start the service.
* `:stop` – Stop the service.
* `:restart` – Stop and then start the service.
* `:reload` – Send the configured reload signal to the service.

#### Properties

* `path` – Base path for the application. *(name attribute)*
* `port` – Port to listen on. *(default: 80)*
* `service_name` – Name of the service to create. *(default: auto-detect)*
* `user` – User to run the service as. *(default: application owner)*

## Sponsors

Development sponsored by [Chef Software](https://www.chef.io/), [Symonds & Son](http://symondsandson.com/), and [Orion](https://www.orionlabs.co/).

The Poise test server infrastructure is sponsored by [Rackspace](https://rackspace.com/).

## License

Copyright 2015-2017, Noah Kantrowitz

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
