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

require 'poise/backports'
require 'poise/utils'
require 'poise_application/app_mixin'
require 'poise_ruby/ruby_command_mixin'


module PoiseApplicationRuby
  # A helper mixin for Ruby application resources and providers.
  #
  # @since 4.0.0
  module AppMixin
    include Poise::Utils::ResourceProviderMixin

    # A helper mixin for Ruby application resources.
    module Resource
      include PoiseApplication::AppMixin::Resource
      include PoiseRuby::RubyCommandMixin::Resource

      # @!attribute parent_ruby
      #   Override the #parent_ruby from RubyCommandMixin to grok the
      #   application level parent as a default value.
      #   @return [PoiseRuby::Resources::RubyRuntime::Resource, nil]
      parent_attribute(:ruby, type: :ruby_runtime, optional: true, default: lazy { app_state_ruby.equal?(self) ? nil : app_state_ruby })

      # @!attribute parent_bundle
      #   Parent bundle install context.
      #   @return [PoiseRuby::Resources::BundleInstall::Resource, nil]
      parent_attribute(:bundle, type: :ruby_runtime, optional: true, auto: false, default: lazy { app_state_bundle.equal?(self) ? nil : app_state_bundle })

      # @attribute app_state_ruby
      #   The application-level Ruby parent.
      #   @return [PoiseRuby::Resources::RubyRuntime::Resource, nil]
      def app_state_ruby(ruby=Poise::NOT_PASSED)
        unless ruby == Poise::NOT_PASSED
          app_state[:ruby] = ruby
        end
        app_state[:ruby]
      end

      # @attribute app_state_bundle
      #   The application-level Bundle parent.
      #   @return [PoiseRuby::Resources::BundleInstall::Resource, nil]
      def app_state_bundle(bundle=Poise::NOT_PASSED)
        unless bundle == Poise::NOT_PASSED
          app_state[:bundle] = bundle
        end
        app_state[:bundle]
      end

      # A merged hash of environment variables for both the application state
      # and parent ruby.
      #
      # @return [Hash<String, String>]
      def app_state_environment_ruby
        env = app_state_environment
        env = env.merge(parent_ruby.ruby_environment) if parent_ruby
        env['BUNDLE_GEMFILE'] = parent_bundle.gemfile_path if parent_bundle
        env
      end

      # Update ruby_from_parent to transfer {#parent_bundle} too.
      #
      # @param resource [Chef::Resource] Resource to inherit from.
      # @return [void]
      def ruby_from_parent(resource)
        super
        parent_bundle(resource.parent_bundle) if resource.parent_bundle
      end
    end

    # A helper mixin for Ruby application providers.
    module Provider
      include PoiseApplication::AppMixin::Provider
    end
  end
end
