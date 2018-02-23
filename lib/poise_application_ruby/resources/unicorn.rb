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

require 'poise_application_ruby/service_mixin'


module PoiseApplicationRuby
  module Resources
    # (see Unicorn::Resource)
    # @since 4.0.0
    module Unicorn
      # An `application_unicorn` resource to manage a unicorn web application
      # server.
      #
      # @since 4.0.0
      # @provides application_unicorn
      # @action enable
      # @action disable
      # @action start
      # @action stop
      # @action restart
      # @action reload
      # @example
      #   application '/srv/myapp' do
      #     git '...'
      #     bundle_install
      #     unicorn do
      #       port 8080
      #     end
      #   end
      class Resource < Chef::Resource
        include PoiseApplicationRuby::ServiceMixin
        provides(:application_unicorn)

        # @!attribute port
        #   Port to bind to.
        attribute(:port, kind_of: [String, Integer], default: 80)

        # @!attribute socket
        #   Listen on a unix socket instead of a port
        attribute(:socket, kind_of: [TrueClass, FalseClass], default: false)
      end

      # Provider for `application_unicorn`.
      #
      # @since 4.0.0
      # @see Resource
      # @provides application_unicorn
      class Provider < Chef::Provider
        include PoiseApplicationRuby::ServiceMixin
        provides(:application_unicorn)

        private

        # Find the path to the config.ru. If the resource path was to a
        # directory, apparent /config.ru.
        #
        # @return [String]
        def configru_path
          @configru_path ||= if ::File.directory?(new_resource.path)
            ::File.join(new_resource.path, 'config.ru')
          else
            new_resource.path
          end
        end

        # Path to the socket file.
        #
        # @return [String]
        def socket_path
          @socket_path ||= "unix:///var/run/#{::File.basename(new_resource.path)}.sock"
        end

        # Set service resource options.
        def service_options(resource)
          super
          unless new_resource.socket
            resource.ruby_command("unicorn --port #{new_resource.port} #{configru_path}")
          else
            resource.ruby_command("unicorn -l #{socket_path} #{configru_path}")
          end
        end
      end
    end
  end
end
