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

require 'poise/utils'
require 'poise_application/service_mixin'
require 'poise_languages/utils'
require 'poise_ruby/bundler_mixin'

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
      include PoiseRuby::RubyCommandMixin::Provider
      include PoiseRuby::BundlerMixin

      # Set up the service for running Ruby stuff.
      def service_options(resource)
        super
        # Closure scoping for #ruby_command below.
        self_ = self
        # Create a new singleton method that fills in Python for you.
        resource.define_singleton_method(:ruby_command) do |val|
          path = self_.new_resource.app_state_environment_ruby['PATH'] || ENV['PATH']
          cmd = if self_.new_resource.parent_bundle
            bundle_exec_command(val, path: path)
          else
            # Insert the gem executable directory at the front of the path.
            gem_environment = self_.send(:ruby_shell_out!, self_.new_resource.gem_binary, 'environment')
            matches = gem_environment.stdout.scan(/EXECUTABLE DIRECTORY: (.*)$/).first
            if matches
              Chef::Log.debug("[#{new_resource}] Prepending gem executable directory #{matches.first} to existing $PATH (#{path})")
              path = "#{matches.first}:#{path}"
            end
            "#{self_.new_resource.ruby} #{PoiseLanguages::Utils.absolute_command(val, path: path)}"
          end
          resource.command(cmd)
        end
        # Include env vars as needed.
        resource.environment.update(new_resource.parent_ruby.ruby_environment) if new_resource.parent_ruby
        resource.environment['BUNDLE_GEMFILE'] = new_resource.parent_bundle.gemfile_path if new_resource.parent_bundle
      end

    end
  end
end
