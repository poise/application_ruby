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

# There is a bug in Poise, this is a workaround
if platform_family?('rhel')
  include_recipe 'build-essential'
end

package 'ruby'

if platform?('ubuntu') && node['platform_version'] == '12.04'
  # For old Ubuntu
  package 'rubygems'
  package 'net-tools'
end

if platform_family?('rhel') && node['platform_version'].start_with?('6')
  package 'rubygems'
end

gem_package 'rack'

# Webrick on Ruby 1.8 and 1.9 doesn't exit on SIGTERM, so use SIGKILL instead.
node.override['poise-service']['rack1']['control']['t'] = 'sv kill rack1'
node.override['poise-service']['rack2']['control']['t'] = 'sv kill rack2'

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
