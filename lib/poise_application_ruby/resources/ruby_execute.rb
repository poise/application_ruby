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

require 'poise_ruby/resources/ruby_execute'

require 'poise_application_ruby/app_mixin'


module PoiseApplicationRuby
  module Resources
    # (see RubyExecute::Resource)
    # @since 4.0.0
    module RubyExecute
      # An `application_ruby_execute` resource to run Ruby commands inside an
      # Application cookbook deployment.
      #
      # @provides application_ruby_execute
      # @action run
      # @example
      #   application '/srv/myapp' do
      #     ruby_execute 'rake build'
      #   end
      class Resource < PoiseRuby::Resources::RubyExecute::Resource
        include PoiseApplicationRuby::AppMixin
        provides(:application_ruby_execute)
        subclass_providers!

        # #!attribute cwd
        #   Override the default directory to be the app path if unspecified.
        #   @return [String]
        attribute(:cwd, kind_of: [String, NilClass, FalseClass], default: lazy { parent && parent.path })
      end

    end
  end
end
