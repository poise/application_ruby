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

require 'spec_helper'

describe PoiseApplicationRuby::Resources::RubyExecute do
  step_into(:application_ruby_execute)
  recipe do
    application '/srv/myapp' do
      owner 'myuser'
      group 'mygroup'
      environment ENVKEY: 'ENVVALUE'

      ruby('') { provider :dummy }
      ruby_execute 'myapp.rb'
    end
  end

  it do
    expect_any_instance_of(described_class::Provider).to receive(:shell_out!).with(
      '/ruby myapp.rb',
      user: 'myuser',
      group: 'mygroup',
      cwd: '/srv/myapp',
      timeout: 3600,
      returns: 0,
      environment: {'ENVKEY' => 'ENVVALUE'},
      log_level: :info,
      log_tag: 'application_ruby_execute[myapp.rb]',
    )
    is_expected.to run_application_ruby_execute('myapp.rb').with(user: 'myuser', group: 'mygroup', cwd: '/srv/myapp')
  end
end
