#
# Copyright 2015, Noah Kantrowitz
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


module PoiseApplicationRuby
  module Resources
    # (see Rack::Resource)
    module Rack
      # An `application_rack` resource to configure Ruby on Rack applications.
      #
      # @since 4.1.0
      # @provides application_rack
      # @action deploy
      # @example
      #   application '/srv/myapp' do
      #     git '...'
      #     bundle_install
      #     rack do
      #       dotenv do
      #         zookeeper_dsn '127.0.0.1,127.0.1.1,127.0.2.1/corporate.com'
      #       end
      #     end
      #     puma do
      #       port 8080
      #     end
      #   end
      class Resource < Chef::Resource
        include PoiseApplicationRuby::AppMixin
        provides(:application_rack)
        actions(:deploy)

        # @!attribute dotenv
        #   Option collector attribute for Rack dotenv configuration.
        # @example Setting via block
        #   dotenv do
        #     zookeeper_dsn '127.0.0.1,127.0.1.1,127.0.2.1/corporate.com'
        #   end
        # @example Setting via Hash
        #   environment Hash.new(zookeeper_dsn: '127.0.0.1,127.0.1.1,127.0.2.1/corporate.com')
        attribute(:dotenv, option_collector: true, default: lazy { default_dotenv_options })
        # @!attribute migrate
        #   Run database migrations. This is a bad idea for real apps. Please
        #   do not use it.
        #   @return [Boolean]
        attribute(:migrate, equal_to: [true, false], default: false)
        # @!attribute rack_env
        #   Rack environment name. Defaults to the Chef environment name or
        #   `production` if none is set.
        #   @see #default_rack_env
        #   @return [String]
        attribute(:rack_env, kind_of: String, default: lazy { default_rack_env })

        private

        # Check the default environment name.
        #
        # @return [String]
        def default_rack_env
          node.chef_environment == '_default' ? 'production' : node.chef_environment
        end

        # Default template variables for the .env.
        #
        # @return [Hash<Symbol, Object>]
        def default_dotenv_options
          {
            rack_env: rack_env
          }
        end
      end

      # Provider for `application_rack`.
      #
      # @since 4.1.0
      # @see Resource
      # @provides application_rack
      class Provider < Chef::Provider
        include PoiseApplicationRuby::AppMixin
        provides(:application_rack)

        # `deploy` action for `application_rack`. Ensure all configuration
        # files are created and other deploy tasks resolved.
        #
        # @return [void]
        def action_deploy
          set_state
          notifying_block do
            write_dotenv_config unless new_resource.dotenv.empty?
            run_migrations if new_resource.migrate
          end
        end

        private

        # Set app_state variables for future services et al.
        def set_state
          new_resource.app_state_environment[:RACK_ENV] = new_resource.rack_env
        end

        # Create a dotenv config file.
        def write_dotenv_config
          rc_file ::File.join(new_resource.path, '.env') do
            type 'bash'
            user new_resource.parent.owner
            group new_resource.parent.group
            mode '640'
            options(new_resource.dotenv)
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
