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
require 'poise'
require 'poise_application'
require 'poise_service/resource'

require 'poise_application_ruby/error'

module PoiseApplicationRuby
  module Resources
    # (see Rackup::Resource)
    # @since 4.0.0
    module Rackup
      class Resource < Chef::Resource
        # base
        #include Poise(parent: PoiseApplication::Resources::Application::Resource, parent_optional: true)
        include Poise(parent: Chef::Resource::Application, parent_optional: true)
        provides(:rackup)
        actions(:enable, :disable, :restart)

        # base
        attribute(:path, kind_of: String, name_attribute: true)
        # @todo Deal with this being nil
        attribute(:service_name, kind_of: String, default: lazy { parent && parent.service_name })
        attribute(:user, kind_of: [String, Integer], default: lazy { parent ? parent.owner : 'root' })

        # sub
        attribute(:port, kind_of: [String, Integer], default: 80)
      end

      class Provider < Chef::Provider
        # base
        include Poise
        provides(:rackup)

        # base
        def action_enable
          notify_if_service do
            service_resource.run_action(:enable)
          end
        end

        # base
        def action_disable
          notify_if_service do
            service_resource.run_action(:disable)
          end
        end

        # base
        def action_restart
          notify_if_service do
            service_resource.run_action(:restart)
          end
        end

        # @todo Add reload once poise-service supports it.

        private

        # sub
        def configru_path
          @configru_path ||= if ::File.directory?(new_resource.path)
            ::File.join(new_resource.path, 'config.ru')
          else
            new_resource.path
          end
        end

        # base
        def notify_if_service(&block)
          service_resource.updated_by_last_action(false)
          block.call
          new_resource.updated_by_last_action(true) if service_resource.updated_by_last_action?
        end

        # base
        def service_resource
          @service_resource ||= PoiseService::Resource.new(new_resource.name, run_context).tap do |r|
            # Set some defaults based on the resource and possibly the app.
            r.service_name(new_resource.service_name)
            r.directory(::File.dirname(configru_path))
            r.user(new_resource.user)
            # Call the subclass hook for more specific settings.
            service_options(r)
          end
        end

        # abstract
        def service_options(r)
          # @todo handle gemfile/bundle exec here (via a mixin)
          r.command("rackup --port #{new_resource.port}")
        end
      end
    end
  end
end
