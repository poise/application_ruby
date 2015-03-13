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

directory '/opt/bundle1'

file '/opt/bundle1/Gemfile' do
  content <<-EOH
source 'https://rubygems.org/'
gem 'rake'
EOH
end

bundle_install '/opt/bundle1/Gemfile'

# Nuke it if needed, tests for notifications require starting from scratch
execute 'rm -rf /opt/bundle2' if File.exists?('/opt/bundle2')

directory '/opt/bundle2'

file '/opt/bundle2/Gemfile' do
  content <<-EOH
source 'https://rubygems.org/'
gem 'rake'
EOH
end

file '/opt/bundle2/Gemfile.lock' do
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

file '/opt/bundle2/sentinel1' do
  action :nothing
  content ''
end

bundle_install '/opt/bundle2/Gemfile' do
  deployment true
  binstubs true
  notifies :create, 'file[/opt/bundle2/sentinel1]', :immediately
end

file '/opt/bundle2/sentinel2' do
  action :nothing
  content ''
end

bundle_install '/opt/bundle2/Gemfile again' do
  path '/opt/bundle2/Gemfile'
  deployment true
  binstubs true
  notifies :create, 'file[/opt/bundle2/sentinel2]', :immediately
end
