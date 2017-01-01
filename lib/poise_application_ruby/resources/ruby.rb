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

require 'poise_ruby/resources/ruby_runtime'

require 'poise_application_ruby/app_mixin'


module PoiseApplicationRuby
  module Resources
    # (see Ruby::Resource)
    # @since 4.0.0
    module Ruby
      # An `application_ruby` resource to manage Ruby runtimes
      # inside an Application cookbook deployment.
      #
      # @provides application_ruby
      # @provides application_ruby_runtime
      # @action install
      # @action uninstall
      # @example
      #   application '/app' do
      #     ruby '2'
      #   end
      class Resource < PoiseRuby::Resources::RubyRuntime::Resource
        include PoiseApplicationRuby::AppMixin
        provides(:application_ruby)
        provides(:application_ruby_runtime)
        container_default(false)
        subclass_providers!

        # Rebind the parent class #gem_binary instead of the one from
        # RubyCommandMixin (by way of AppMixin)
        def gem_binary(*args, &block)
          self.class.superclass.instance_method(:gem_binary).bind(self).call(*args, &block)
        end

        # Set this resource as the app_state's parent ruby.
        #
        # @api private
        def after_created
          super.tap do |val|
            app_state_ruby(self)
          end
        end

      end
    end
  end
end
