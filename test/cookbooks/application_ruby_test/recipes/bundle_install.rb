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

package 'ruby'

directory '/opt/test1'

file '/opt/test1/Gemfile' do
  content <<-EOH
source 'https://rubygems.org/'
gem 'rake'
EOH
end

bundle_install '/opt/test1/Gemfile'

# Nuke it if needed, tests for notifications require starting from scratch
execute 'rm -rf /opt/test2' if File.exists?('/opt/test2')

directory '/opt/test2'

file '/opt/test2/Gemfile' do
  content <<-EOH
source 'https://rubygems.org/'
gem 'rake'
EOH
end

file '/opt/test2/Gemfile.lock' do
  content <<-EOH
GEM
  remote: https://rubygems.org/
  specs:
    rake (10.4.2)

PLATFORMS
  ruby

DEPENDENCIES
  rake
EOH
end

file '/opt/test2/sentinel1' do
  action :nothing
  content ''
end

bundle_install '/opt/test2/Gemfile' do
  deployment true
  binstubs true
  notifies :create, 'file[/opt/test2/sentinel1]', :immediately
end

file '/opt/test2/sentinel2' do
  action :nothing
  content ''
end

bundle_install '/opt/test2/Gemfile again' do
  path '/opt/test2/Gemfile'
  deployment true
  binstubs true
  notifies :create, 'file[/opt/test2/sentinel2]', :immediately
end
