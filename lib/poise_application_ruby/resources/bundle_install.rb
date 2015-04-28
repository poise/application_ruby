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
require 'poise_ruby/resources/bundle_install'

require 'poise_application_ruby/error'


module PoiseApplicationRuby
  module Resources
    # (see BundleInstall::Resource)
    # @since 4.0.0
    module BundleInstall
      # An `application_bundle_install` resource to install a
      # [Bundler](http://bundler.io/) Gemfile in a web application.
      #
      # @note
      #   This resource is not idempotent itself, it will always run `bundle
      #   install`.
      # @example
      #   application_bundle_install '/opt/my_app' do
      #     gem_path '/usr/local/bin/gem'
      #   end
      class Resource < PoiseRuby::Resources::BundleInstall::Resource
        parent_type(:application)
        provides(:application_bundle_install)
      end

      # The default provider for the `application_bundle_install` resource.
      #
      # @see Resource
      class Provider < PoiseRuby::Resources::BundleInstall::Provider
        provides(:application_bundle_install)

        def action_install
          super
          set_state
        end

        def action_update
          super
          set_state
        end

        private

        def set_state
          if new_resource.parent
            new_resource.parent.app_state[:bundler_gemfile] = gemfile_path
            new_resource.parent.app_state[:bundler_binary] = bundler_binary
          end
        end
      end
    end
  end
end
