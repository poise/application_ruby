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

require 'poise_ruby/resources/bundle_install'

require 'poise_application_ruby/app_mixin'


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
      #   application '/srv/my_app' do
      #     bundle_install
      #   end
      class Resource < PoiseRuby::Resources::BundleInstall::Resource
        include PoiseApplicationRuby::AppMixin
        provides(:application_bundle_install)
        subclass_providers!

        # Set this resource as the app_state's parent bundle.
        #
        # @api private
        def after_created
          super.tap do |val|
            app_state_bundle(self)
          end
        end
      end

    end
  end
end
