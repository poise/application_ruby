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

require 'poise_ruby/resources/ruby_gem'

require 'poise_application_ruby/app_mixin'


module PoiseApplicationRuby
  module Resources
    # (see RubyGem::Resource)
    # @since 4.0.0
    module RubyGem
      # An `application_ruby_gem` resource to install Ruby gems inside an
      # Application cookbook deployment.
      #
      # @provides application_ruby_gem
      # @action install
      # @action upgrade
      # @action remove
      # @example
      #   application '/srv/myapp' do
      #     ruby_gem 'rack'
      #   end
      class Resource < PoiseRuby::Resources::RubyGem::Resource
        include PoiseApplicationRuby::AppMixin
        provides(:application_ruby_gem)
        subclass_providers!
      end

    end
  end
end
