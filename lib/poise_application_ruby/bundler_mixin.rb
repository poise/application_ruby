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


module PoiseApplicationRuby
  # A mixin for providers that need to run under bundle exec. Expects the
  # parent resource to be an instance of {PoiseApplication::Resources::Application}.
  #
  # @api public
  # @since 4.0.0
  # @see Resources::BundleInstall
  # @example
  #   def service_options(resource)
  #     resource.command("myapp --serve")
  #     bundle_service_options(resource)
  #   end
  module BundlerMixin
    # Return a command string or array modified to run under bundler if needed.
    #
    # @api private
    # @param command [String, Array] Command to modify.
    # @return [String, Array]
    def bundle_exec_command(command)
      if new_resource.parent && new_resource.parent.app_state[:bundler_binary]
        if command.is_a?(Array)
          [new_resource.parent.app_state[:bundler_binary], 'exec'] + command
        else
          "#{new_resource.parent.app_state[:bundler_binary]} exec #{command}"
        end
      else
        command
      end
    end

    # Return environment variables for running under bundler if needed.
    #
    # @api private
    # @return [Hash<String, String>]
    def bundle_exec_environment
      if new_resource.parent && new_resource.parent.app_state[:bundler_gemfile]
        {'BUNDLE_GEMFILE' => new_resource.parent.app_state[:bundler_gemfile]}
      else
        {}
      end
    end

    # Reconfigure a service resource to run under bundle exec if needed.
    #
    # @return [void]
    # @example
    #   def service_options(resource)
    #     resource.command("myapp --serve")
    #     bundle_service_options(resource)
    #   end
    def bundle_service_options(resource)
      resource.command(bundle_exec_command(resource.command)) if resource.command
      resource.environment.update(bundle_exec_environment)
    end
  end
end
