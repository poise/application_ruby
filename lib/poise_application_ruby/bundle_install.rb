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
require 'chef/provider'
require 'chef/resource'
require 'poise'

require 'poise_application_ruby/error'

module PoiseApplicationRuby
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
      include Poise
      provides(:bundle_install)
      actions(:install)

      attribute(:path, name_attribute: true)
      attribute(:user, kind_of: String)
      attribute(:binstubs, kind_of: [TrueClass, String])
      attribute(:development, equal_to: [true, false], default: false)
      attribute(:gem_binary, kind_of: String) # HOW TO FIND THE DEFAULT?
      attribute(:bundler_version, kind_of: String)

      # Absolute path to the gem binary.
      def absolute_gem_binary
        File.expand_path(gem_binary, path)
      end
    end

    # The default provider for the `bundle_install` resource.
    #
    # @see Resource
    class Provider < Chef::Provider
      include Poise
      include Chef::Mixin::ShellOut

      # Install bundler and the gems in the Gemfile.
      def action_install
        install_bundler
        bundle_install
      end

      private

      # Install bundler using the specified gem binary.
      def install_bundler
        notifying_block do
          gem_binary 'bundler' do
            version new_resource.bundler_version
            gem_binary new_resource.gem_binary
          end
        end
      end

      # Install the gems in the Gemfile.
      def bundle_install
      end

      # Parse out the value for Gem.bindir. This is so complicated to minimize
      # the required configuration on the resource combined with gem having
      # terrible output formats.
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
    end
  end
end
