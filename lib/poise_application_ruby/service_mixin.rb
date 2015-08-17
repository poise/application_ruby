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

require 'poise/utils'
require 'poise_application/service_mixin'
require 'poise_languages/utils'

require 'poise_application_ruby/app_mixin'


module PoiseApplicationRuby
  # A helper mixin for Ruby service resources and providers.
  #
  # @since 4.0.0
  module ServiceMixin
    include Poise::Utils::ResourceProviderMixin

    # A helper mixin for Ruby service resources.
    module Resource
      include PoiseApplication::ServiceMixin::Resource
      include PoiseApplicationRuby::AppMixin::Resource
    end

    # A helper mixin for Ruby service providers.
    module Provider
      include PoiseApplication::ServiceMixin::Provider
      include PoiseApplicationRuby::AppMixin::Provider

      # Set up the service for running Ruby stuff.
      def service_options(resource)
        super
        # Closure scoping for #ruby_command below.
        self_ = self
        # Create a new singleton method that fills in Python for you.
        resource.define_singleton_method(:ruby_command) do |val|
          ruby = self_.new_resource.ruby
          cmd = if self_.new_resource.parent_bundle
            "#{ruby} #{self_.new_resource.parent_bundle.bundler_binary} exec #{val}"
          else
            "#{ruby} #{PoiseLanguages::Utils.absolute_command(val, path: self_.new_resource.app_state_environment_ruby['PATH'])}"
          end
          resource.command(cmd)
        end
        # Include env vars as needed.
        resource.environment.update(new_resource.parent_ruby.ruby_environment) if new_resource.parent_ruby
      end

    end
  end
end
