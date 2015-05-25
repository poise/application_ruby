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

# RHEL 6 is too old to run Rails 4.2 on the system Ruby.
return if platform_family?('rhel') && node['platform_version'].start_with?('6')

include_recipe 'build-essential'

package value_for_platform_family(debian: 'ruby-dev', rhel: 'ruby-devel')
package value_for_platform_family(debian: 'zlib1g-dev', rhel: 'zlib-devel')
package value_for_platform_family(debian: 'libsqlite3-dev', rhel: 'sqlite-devel')
package 'tar' if platform_family?('rhel')

application '/opt/test_rails' do
  git 'https://github.com/poise/test_rails.git'
  bundle_install do
    deployment true
    without %w{development test}
  end
  rails do
    database 'sqlite3:///db.sqlite3'
    migrate true
    secret_token 'd78fe08df56c9'
  end
  unicorn do
    port 9001
  end
end
