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

require 'chef/mixin/shell_out'
require 'chef/mixin/which'
require 'chef/provider'
require 'chef/resource'
require 'poise'
require 'poise_application/resources/application'

require 'poise_application_ruby/error'

module PoiseApplicationRuby
  module Resources
    # (see BundleInstall::Resource)
    # @since 4.0.0
    module BundleInstall
      # A `bundle_install` resource to install a [Bundler](http://bundler.io/)
      # Gemfile.
      #
      # @note
      #   This resource is not idempotent itself, it will always run `bundle
      #   install`.
      # @example
      #   bundle_install '/opt/my_app' do
      #     gem_path '/usr/local/bin/gem'
      #   end
      class Resource < Chef::Resource
        include Poise(parent: Chef::Resource::Application, parent_optional: true)
        include Chef::Mixin::Which
        provides(:bundle_install)
        actions(:install, :update)

        attribute(:path, name_attribute: true)
        attribute(:user, kind_of: String)
        attribute(:binstubs, kind_of: [TrueClass, String])
        attribute(:vendor, kind_of: [TrueClass, String])
        attribute(:deployment, equal_to: [true, false], default: false)
        attribute(:without, kind_of: [Array, String])
        attribute(:jobs, kind_of: [String, Integer])
        attribute(:retry, kind_of: [String, Integer])
        attribute(:gem_binary, kind_of: String, default: lazy { which('gem') })
        attribute(:bundler_version, kind_of: String)

        # Absolute path to the gem binary.
        def absolute_gem_binary
          ::File.expand_path(gem_binary, path)
        end
      end

      # The default provider for the `bundle_install` resource.
      #
      # @see Resource
      class Provider < Chef::Provider
        include Poise
        include Chef::Mixin::ShellOut
        provides(:bundle_install)

        # Install bundler and the gems in the Gemfile.
        def action_install
          install_bundler
          run_bundler('install')
          set_state
        end

        # Install bundler and update the gems in the Gemfile.
        def action_update
          install_bundler
          run_bundler('update')
          set_state
        end

        private

        # Install bundler using the specified gem binary.
        def install_bundler
          # This doesn't use the DSL to keep things simpler and so that a change
          # in the bundler version doesn't trigger a notification on the resource.
          Chef::Resource::GemPackage.new('bundler', run_context).tap do |r|
            r.action(:upgrade) unless new_resource.bundler_version
            r.version(new_resource.bundler_version)
            r.gem_binary(new_resource.absolute_gem_binary)
            r.run_action(*Array(r.action))
          end
        end

        # Install the gems in the Gemfile.
        def run_bundler(command)
          return converge_by "Run bundle #{command}" if whyrun_mode?
          cmd = shell_out!(bundler_command(command), environment: {'BUNDLE_GEMFILE' => gemfile_path})
          # Look for a line like 'Installing $gemname $version' to know if we did anything.
          if cmd.stdout.include?('Installing')
            new_resource.updated_by_last_action(true)
          end
        end

        def set_state
          if new_resource.parent
            new_resource.parent.app_state[:bundler_gemfile] = gemfile_path
            new_resource.parent.app_state[:bundler_binary] = bundler_binary
          end
        end

        # Parse out the value for Gem.bindir. This is so complicated to minimize
        # the required configuration on the resource combined with gem having
        # terrible output formats.
        #
        # @return [String]
        def gem_bindir
          cmd = shell_out!([new_resource.absolute_gem_binary, 'environment'])
          # Parse a line like:
          # - EXECUTABLE DIRECTORY: /usr/local/bin
          matches = cmd.stdout.scan(/EXECUTABLE DIRECTORY: (.*)$/).first
          if matches
            matches.first
          else
            raise Error.new("Cannot find EXECUTABLE DIRECTORY: #{cmd.stdout}")
          end
        end

        # Return the absolute path to the correct bundle binary to run.
        #
        # @return [String]
        def bundler_binary
          @bundler_binary ||= ::File.join(gem_bindir, 'bundle')
        end

        # Command line options for the bundle install.
        #
        # @return [Array<String>]
        def bundler_options
          [].tap do |opts|
            if new_resource.binstubs
              opts << "--binstubs" + (new_resource.binstubs.is_a?(String) ? "=#{new_resource.binstubs}" : '')
            end
            if new_resource.vendor
              opts << "--path=" + (new_resource.vendor.is_a?(String) ? new_resource.vendor : 'vendor/bundle')
            end
            if new_resource.deployment
              opts << '--deployment'
            end
            if new_resource.jobs
              opts << "--jobs=#{new_resource.jobs}"
            end
            if new_resource.retry
              opts << "--retry=#{new_resource.retry}"
            end
            if new_resource.without
              opts << '--without'
              opts.insert(-1, *new_resource.without)
            end
          end
        end

        # Command array to run when installing the Gemfile.
        #
        # @return [Array<String>]
        def bundler_command(command)
          [bundler_binary, command] + bundler_options
        end

        # Find the absolute path to the Gemfile. This mirrors bundler's internal
        # search logic by scanning up to parent folder as needed.
        #
        # @return [String]
        def gemfile_path
          @gemfile_path ||= begin
            path = ::File.expand_path(new_resource.path)
            if ::File.file?(path)
              # We got a path to a real file, use that.
              path
            else
              # Walk back until path==dirname(path) meaning we are at the root
              while path != (next_path = ::File.dirname(path))
                possible_path = ::File.join(path, 'Gemfile')
                return possible_path if ::File.file?(possible_path)
                path = next_path
              end
            end
          end
        end

      end
    end
  end
end
