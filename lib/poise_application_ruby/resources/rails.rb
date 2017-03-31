#
# Copyright 2015-2017, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/provider'
require 'chef/resource'

require 'poise_application_ruby/app_mixin'
require 'poise_application_ruby/error'


module PoiseApplicationRuby
  module Resources
    # (see Rails::Resource)
    module Rails
      # An `application_rails` resource to configure Ruby on Rails applications.
      #
      # @since 4.0.0
      # @provides application_rails
      # @action deploy
      # @example
      #   application '/srv/myapp' do
      #     git '...'
      #     bundle_install
      #     rails do
      #       database do
      #         host node['rails_host']
      #       end
      #     end
      #     unicorn do
      #       port 8080
      #     end
      #   end
      class Resource < Chef::Resource
        include PoiseApplicationRuby::AppMixin
        provides(:application_rails)
        actions(:deploy)

        # @!attribute app_module
        #   Top-level application module. Only needed for the :initializer style
        #   of secret token configuration, and generally auto-detected.
        #   @return [String, false, nil]
        attribute(:app_module, kind_of: [String, FalseClass, NilClass], default: lazy { default_app_module })
        # @!attribute database
        #   Option collector attribute for Rails database configuration.
        #   @return [Hash]
        #   @example Setting via block
        #     database do
        #       adapter 'postgresql'
        #       database 'blog'
        #     end
        #   @example Setting via URL
        #     database 'postgresql://localhost/blog'
        attribute(:database, option_collector: true, parser: :parse_database_url)
        # @!attribute database_config
        #   Template content attribute for the contents of database.yml.
        #   @todo Redo this doc to cover the actual attributes created.
        #   @return [Poise::Helpers::TemplateContent]
        attribute(:database_config, template: true, default_source: 'database.yml.erb', default_options: lazy { default_database_options })
        # @!attribute migrate
        #   Run database migrations. This is a bad idea for real apps. Please
        #   do not use it.
        #   @return [Boolean]
        attribute(:migrate, equal_to: [true, false], default: false)
        # @!attribute precompile_assets
        #   Set to true to run rake assets:precompile. By default will try to
        #   auto-detect if Sprockets is in use by looking at config/initializers.
        #   @see #default_precompile_assets
        #   @return [Boolean]
        attribute(:precompile_assets, equal_to: [true, false], default: lazy { default_precompile_assets })
        # @!attribute rails_env
        #   Rails environment name. Defaults to the Chef environment name or
        #   `production` if none is set.
        #   @see #default_rails_env
        #   @return [String]
        attribute(:rails_env, kind_of: String, default: lazy { default_rails_env })
        # @!attribute secret_token
        #   Secret token for Rails session verification and other purposes. On
        #   Rails 4.2 this will be used for secret_key_base. If not set, no
        #   secrets configuration is written.
        #   @return [String, false, nil]
        attribute(:secret_token, kind_of: [String, FalseClass, NilClass])
        # @!attribute secrets_config
        #   Template content attribute for the contents of secrets.yml. Only
        #   used when secrets_mode is :yaml.
        #   @todo Redo this doc to cover the actual attributes created.
        #   @return [Poise::Helpers::TemplateContent]
        attribute(:secrets_config, template: true, default_source: 'secrets.yml.erb', default_options: lazy { default_secrets_options })
        # @!attribute secrets_initializer
        #   Template content attribute for the contents of secret_token.rb. Only
        #   used when secrets_mode is :initializer.
        #   @todo Redo this doc to cover the actual attributes created.
        #   @return [Poise::Helpers::TemplateContent]
        attribute(:secrets_initializer, template: true, default_source: 'secret_token.rb.erb', default_options: lazy { default_secrets_options })
        # @!attribute secrets_mode
        #   Secrets configuration mode. Set to `:yaml` to generate a Rails 4.2
        #   secrets.yml. Set to `:initializer` to update
        #   `config/initializers/secret_token.rb`. If unspecified this is
        #   auto-detected based on what files exist.
        #   @return [Symbol]
        attribute(:secrets_mode, equal_to: [:yaml, :initializer], default: lazy { default_secrets_mode })

        private

        # Check if we should run the precompile by default. Looks for the
        # assets initializer because that is not present with --skip-sprockets.
        #
        # @return [Boolean]
        def default_precompile_assets
          ::File.exists?(::File.join(path, 'config', 'initializers', 'assets.rb'))
        end

        # Check the default environment name.
        #
        # @return [String]
        def default_rails_env
          node.chef_environment == '_default' ? 'production' : node.chef_environment
        end

        # Format a single URL for the database.yml
        #
        # @return [Hash]
        def parse_database_url(url)
          {'url' => url}
        end

        # Default template variables for the database.yml.
        #
        # @return [Hash<Symbol, Object>]
        def default_database_options
          db_config = {'encoding' => 'utf8', 'reconnect' => true, 'pool' => 5}.merge(database)
          {
            config: {
              rails_env => db_config
            },
          }
        end

        # Check which secrets configuration mode is in use based on files.
        #
        # @return [Symbol]
        def default_secrets_mode
          ::File.exists?(::File.join(path, 'config', 'initializers', 'secret_token.rb')) ? :initializer : :yaml
        end

        # Default template variables for the secrets.yml and secret_token.rb.
        #
        # @return [Hash<Symbol, Object>]
        def default_secrets_options
          {
            yaml_config: {
              rails_env => {
                'secret_key_base' => secret_token,
              }
            },
            secret_token: secret_token,
            app_module: if secrets_mode == :initializer
              raise Error.new("Unable to extract app module for #{self}, please set app_module property") if !app_module || app_module.empty?
              app_module
            end
          }
        end

        # Default application module name.
        #
        # @return [String]
        def default_app_module
          IO.read(::File.join(path, 'config', 'initializers', 'secret_token.rb'))[/(\w+)::Application\.config\.secret_token/, 1]
        end
      end

      # Provider for `application_rails`.
      #
      # @since 4.0.0
      # @see Resource
      # @provides application_rails
      class Provider < Chef::Provider
        include PoiseApplicationRuby::AppMixin
        provides(:application_rails)

        # `deploy` action for `application_rails`. Ensure all configuration
        # files are created and other deploy tasks resolved.
        #
        # @return [void]
        def action_deploy
          set_state
          notifying_block do
            write_database_yml unless new_resource.database.empty?
            write_secrets_config if new_resource.secret_token
            precompile_assets if new_resource.precompile_assets
            run_migrations if new_resource.migrate
          end
        end

        private

        # Set app_state variables for future services et al.
        def set_state
          new_resource.app_state_environment[:RAILS_ENV] = new_resource.rails_env
          new_resource.app_state_environment[:DATABASE_URL] = new_resource.database['url'] if new_resource.database['url']
        end

        # Create a database.yml config file.
        def write_database_yml
          file ::File.join(new_resource.path, 'config', 'database.yml') do
            user new_resource.parent.owner
            group new_resource.parent.group
            mode '640'
            content new_resource.database_config_content
          end
        end

        # Dispatch to the correct config writer based on the mode.
        def write_secrets_config
          case new_resource.secrets_mode
          when :yaml
            write_secrets_yml
          when :initializer
            write_secrets_initializer
          else
            raise Error.new("Unknown secrets mode #{new_resource.secrets_mode.inspect}")
          end
        end

        # Write a Rails 4.2-style secrets.yml.
        def write_secrets_yml
          file ::File.join(new_resource.path, 'config', 'secrets.yml') do
            user new_resource.parent.owner
            group new_resource.parent.group
            mode '640'
            content new_resource.secrets_config_content
            sensitive true
          end
        end

        # In-place update a config/initializers/secret_token.rb file.
        def write_secrets_initializer
          file ::File.join(new_resource.path, 'config', 'initializers', 'secret_token.rb') do
            user new_resource.parent.owner
            group new_resource.parent.group
            mode '640'
            content new_resource.secrets_initializer_content
            sensitive true
          end
        end

        # Precompile assets using the rake task.
        def precompile_assets
          # Currently this will always run so the resource will always update :-/
          # Better fix would be to shell_out! and parse the output?
          ruby_execute 'rake assets:precompile' do
            command %w{rake assets:precompile}
            user new_resource.parent.owner
            group new_resource.parent.group
            cwd new_resource.parent.path
            environment new_resource.app_state_environment
            ruby_from_parent new_resource
            parent_bundle new_resource.parent_bundle if new_resource.parent_bundle
          end
        end

        # Run database migrations using the rake task.
        def run_migrations
          # Currently this will always run so the resource will always update :-/
          # Better fix would be to shell_out! and parse the output?
          ruby_execute 'rake db:migrate' do
            command %w{rake db:migrate}
            user new_resource.parent.owner
            group new_resource.parent.group
            cwd new_resource.parent.path
            environment new_resource.app_state_environment
            ruby_from_parent new_resource
            parent_bundle new_resource.parent_bundle if new_resource.parent_bundle
          end
        end

      end
    end
  end
end
