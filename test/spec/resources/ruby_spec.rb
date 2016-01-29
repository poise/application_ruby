#
# Copyright 2015-2016, Noah Kantrowitz
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

require 'spec_helper'

describe PoiseApplicationRuby::Resources::Ruby do
  recipe do
    application '/test' do
      ruby do
        provider :dummy
      end
      ruby_gem 'test'
    end
  end

  it { is_expected.to install_application_ruby('/test').with(ruby_binary: '/ruby', gem_binary: '/gem') }
  it { is_expected.to install_application_ruby_gem('test').with(ruby: '/ruby', gem_binary: '/gem') }
end
