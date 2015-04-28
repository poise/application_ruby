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

require 'shellwords'

require 'chef/mixin/shell_out'
require 'poise/utils/resource_provider_mixin'

require 'poise_application_ruby/error'


module PoiseApplicationRuby
  # A mixin for providers that might run under bundle exec. Expects the
  # parent resource to be an instance of {PoiseApplication::Resources::Application}.
  #
  # @since 4.0.0
  # @see Resources::BundleInstall
  # @example
  #   def service_options(resource)
  #     resource.command("myapp --serve")
  #     bundle_service_options(resource)
  #   end
  module RubyMixin
    include Poise::Utils::ResourceProviderMixin

    module Resource
      def self.included(klass)
        klass.parent_attribute(:ruby, type: :ruby_runtime, optional: true)
      end
    end

    module Provider
      include Chef::Mixin::ShellOut

      private

      # Parse out the value for Gem.bindir. This is so complicated to minimize
      # the required configuration on the resource combined with gem having
      # terrible output formats.
      #
      # @return [String]
      def ruby_gem_bindir
        cmd = shell_out!([new_resource.parent_ruby.gem_binary, 'environment'])
        # Parse a line like:
        # - EXECUTABLE DIRECTORY: /usr/local/bin
        matches = cmd.stdout.scan(/EXECUTABLE DIRECTORY: (.*)$/).first
        if matches
          matches.first
        else
          raise PoiseApplicationRuby::Error.new("Cannot find EXECUTABLE DIRECTORY: #{cmd.stdout}")
        end
      end

      # Return a command string or array modified to run under bundler if needed.
      #
      # @api private
      # @param command [String, Array] Command to modify.
      # @return [String, Array]
      def ruby_mixin_command(command)
        if new_resource.parent && new_resource.parent.app_state[:bundler_binary]
          if command.is_a?(Array)
            [new_resource.parent.app_state[:bundler_binary], 'exec'] + command
          else
            "#{new_resource.parent.app_state[:bundler_binary]} exec #{command}"
          end
        elsif new_resource.parent_ruby && new_resource.parent_ruby.gem_binary
          is_array = true
          if !command.is_a?(Array)
            is_array = false
            command = Shellwords.split(command)
          end
          binary = command.shift
          command = [::File.expand_path(binary, ruby_gem_bindir)] + command
          if !is_array
            command = Shellwords.join(command)
          end
          command
        else
          command
        end
      end

      # Return environment variables for running under bundler if needed.
      #
      # @api private
      # @return [Hash<String, String>]
      def ruby_mixin_environment
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
      #      super
      #     resource.command("myapp --serve")
      #   end
      def service_options(resource)
        # HERE BE DRAGONS!
        super if defined?(super)

        # Closure scoping for below.
        self_ = self

        # Patch the command method.
        old_command = resource.method(:command)
        resource.define_singleton_method(:command) do |val=nil|
          val = self_.send(:ruby_mixin_command, val) if val
          old_command.call(val)
        end

        # Patch the environment method.
        old_environment = resource.method(:environment)
        resource.define_singleton_method(:environment) do |val=nil|
          val = val.merge(self_.send(:ruby_mixin_environment)) if val
          result = old_environment.call(val)
          # Just in case no environment is set.
          result = result.merge(self_.send(:ruby_mixin_environment)) if result
          result
        end
      end
    end
  end
end
