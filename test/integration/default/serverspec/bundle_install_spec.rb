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

require 'serverspec'
set :backend, :exec

describe 'bundle_install' do
  describe 'system-level install' do
    rake_binary = case os[:family]
      when 'debian', 'ubuntu'
        '/usr/local/bin/rake'
      when 'redhat'
        '/usr/bin/rake'
      end

    describe file(rake_binary) do
      it { is_expected.to be_a_file }
    end

    describe command("#{rake_binary} --version") do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end

  describe 'deployment install' do
    describe file('/opt/bundle2/bin/rake') do
      it { is_expected.to be_a_file }
    end

    describe command('/opt/bundle2/bin/rake --version') do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to include('10.4.2') }
    end

    describe 'notifications' do
      describe file('/opt/bundle2/sentinel1') do
        it { is_expected.to be_a_file }
      end

      describe file('/opt/bundle2/sentinel2') do
        it { is_expected.to_not be_a_file }
      end
    end
  end
end
