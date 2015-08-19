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

require 'net/http'

require 'serverspec'
set :backend, :exec

describe 'rackup' do
  context '/opt/rack1' do
    describe port(8000) do
      it { is_expected.to be_listening }
    end

    describe 'HTTP response' do
      subject { Net::HTTP.new('localhost', 8000).get('/').body }
      it { is_expected.to eq 'Hello world' }
    end
  end # /context /opt/rack1

  context '/opt/rack2' do
    describe port(8001) do
      it { is_expected.to be_listening }
    end

    describe 'HTTP response' do
      subject { Net::HTTP.new('localhost', 8001).get('/').body }
      it { is_expected.to start_with '/opt/rack2' }
    end
  end # /context /opt/rack2
end
