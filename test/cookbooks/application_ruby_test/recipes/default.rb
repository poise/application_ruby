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

# For netstat in serverspec.
package 'net-tools'

ruby_runtime 'any' do
  provider :system
  version ''
end

ruby_gem 'rack'

application '/opt/rack1' do
  file '/opt/rack1/config.ru' do
    content <<-EOH
use Rack::ContentLength
run proc {|env| [200, {'Content-Type' => 'text/plain'}, ['Hello world']] }
EOH
  end

  rackup do
    port 8000
  end
end

application '/opt/rack2' do
  file '/opt/rack2/Gemfile' do
    content <<-EOH
source 'https://rubygems.org/'
gem 'rack'
EOH
  end

  file '/opt/rack2/config.ru' do
    content <<-EOH
use Rack::ContentLength
run proc {|env| [200, {'Content-Type' => 'text/plain'}, [caller.first]] }
EOH
  end

  bundle_install do
    vendor true
  end

  rackup do
    port 8001
  end
end
