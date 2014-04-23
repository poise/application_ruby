Description
===========

This cookbook is designed to be able to describe and deploy Ruby web applications. Currently supported:

* Ruby on Rails
* Apache 2 with Passenger
* Unicorn
* Memcached client

Note that this cookbook provides the Ruby-specific bindings for the `application` cookbook; you will find general documentation in that cookbook.

Other application stacks may be supported at a later date.

Requirements
============

Chef 11.0.0 or higher required (for Chef environment use).

The following Opscode cookbooks are dependencies:

* application
* apache2
* passenger_apache2
* runit
* unicorn

Resources/Providers
==========

The LWRPs provided by this cookbook are not meant to be used by themselves; make sure you are familiar with the `application` cookbook before proceeding.

rails
------

The `rails` sub-resource LWRP deals with deploying Ruby on Rails webapps from an SCM repository. It uses the `deploy_revision` LWRP to perform the bulk of its tasks, and many concepts and parameters map directly to it. Check the documentation for `deploy_revision` for more information.

For applications that use Bundler, if a Gemfile.lock is present then gems will be installed with `bundle install --deployment`, which results in gems being installed inside the application directory.

When running Bundler, unnecessary groups will be skipped. The list of groups to skip is determined with this algorithm:

* start with this Array: `development test cucumber staging production`;
* the group corresponding to the current environment will be removed from the Array;
* if the `bundler_without_groups` attribute is set, those groups will be added to the Array.

For example, for a node running in the `production` Chef environment, and given:

    bundler_without_groups ["mysql"]

Bundler will be run with:

    bundle install --without development test cucumber staging mysql

# Attribute Parameters

- gems: an Array of gems to install
- bundler: if true, `bundler` will always be used; if false it will never be. Defaults to true if `gems` includes bundler
- bundle\_command: The command to execute when calling bundler commands.  Useful for specifing alternate commands such as RVM wrappers.  Defaults to `bundle`.
- bundle\_options: additional options which will be appended to the end of the `bundle` command string. Useful for capturing the output to a file using the tee command
e.g. `bundle_options "2>&1 | tee -a \some\log\file.log"` 
- bundler\_deployment: if true, Bundler will be run with the `--deployment` options. Defaults to true if a `Gemfile.lock` is present
- bundler\_without\_groups: an Array of additional Bundler groups to skip
- database\_master\_role: if a role name is provided, a Chef search will be run to find a node with the role in the same environment as the current role. If a node is found, its IP address will be used when rendering the `database.yml` file, but see the "Database block parameters" section below
- database\_template: the name of the template that will be rendered to create the `database.yml` file; if specified it will be looked up in the application cookbook. Defaults to "database.yml.erb" from this cookbook
- database: a block containing additional parameters for configuring the database connection
- precompile\_assets: if true, precompile assets for the Rails 3 asset pipeline. The default is nil, in which case we will try to autodetect whether the pipeline is in use by looking for `config/assets.yml`

# Database and memcached block parameters

The database and memcached blocks can accept any method, which will result in an entry being created in the `@database` and `@memcached_envs` Hashes which are passed to the respective templates. See Usage below for more information.

passenger\_apache2
------------------

The `passenger_apache2` sub-resource LWRP configures Apache 2 with Passenger to run the application.

# Attribute Parameters

- server\_aliases: an Array of server aliases
- webapp\_template: the template to render to create the virtual host configuration. Defaults to "#{application name}.conf.erb"
- params: an Hash of extra parameters that will be passed to the template

unicorn
-------

The `unicorn` sub-resource LWRP configures Unicorn to run the application.

# Attribute Parameters

- bundler: if true, Unicorn will be run with `bundle exec`; if false it will be installed and run from the default gem path. Defaults to inheriting this setting from the rails LWRP
- preload_app: passed to the `unicorn_config` LWRP
- worker_processes: passed to the `unicorn_config` LWRP
- before_exec: passed to the `unicorn_config` LWRP
- before_fork: passed to the `unicorn_config` LWRP
- after_fork: passed to the `unicorn_config` LWRP
- port: passed to the `unicorn_config` LWRP
- listen: passed to the `unicorn_config` LWRP; overrides port
- worker_timeout: passed to the `unicorn_config` LWRP
- forked_user: passed to the `unicorn_config` LWRP
- forked_group: passed to the `unicorn_config` LWRP
- pid: passed to the `unicorn_config` LWRP
- stderr_path: passed to the `unicorn_config` LWRP
- stdout_path: passed to the `unicorn_config` LWRP
- unicorn_command_line: passed to the `unicorn_config` LWRP
- copy_on_write: passed to the `unicorn_config` LWRP
- enable_stats: passed to the `unicorn_config` LWRP
- runit_template_cookbook: specify which cookbook to look for unicorn runit templates in

memcached
---------

The `memcached` sub-resource LWRP manages configuration for a Rails-compatible Memcached client.

# Attribute Parameters

- role: a Chef search will be run to find a node with the role in the same environment as the current node. If a node is found, its IP address will be used when rendering the `memcached.yml` file.
- options: a block containing additional parameters for configuring the memcached client

Usage
=====

A sample application that needs a database connection:

    application "redmine" do
      path "/usr/local/www/redmine"

      rails do
        database do
          database "redmine"
          username "redmine"
          password "awesome_password"
        end
        database_master_role "redmine_database_master"
      end

      passenger_apache2 do
      end
    end

You can invoke any method on the database block:

    application "my-app" do
      path "..."
      repository "..."
      revision "..."

      rails do
        database_master_role "my-app_database_master"
        database do
          database 'name'
          quorum 2
          replicas %w[Huey Dewey Louie]
        end
      end
    end

The corresponding entries will be passed to the context template:

    <%= @database['quorum'] %>
    <%= @database['replicas'].join(',') %>

A sample application that connects to memcached:

    application "my-app" do
      path "..."
      repository "..."
      revision "..."

      memcached do
        role "memcached_master"
        options do
          ttl 1800
          memory 256
        end
      end
    end

This will generate a config/memcached.yml file:

    production:
      ttl: 1800
      memory: 256
      servers:
        - 192.168.0.10:11211

License and Author
==================

Author:: Adam Jacob (<adam@opscode.com>)
Author:: Andrea Campi (<andrea.campi@zephirworks.com.com>)
Author:: Joshua Timberman (<joshua@opscode.com>)
Author:: Seth Chisamore (<schisamo@opscode.com>)

Copyright 2009-2012, Opscode, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
