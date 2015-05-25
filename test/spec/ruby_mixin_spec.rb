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

describe PoiseApplicationRuby::RubyMixin do
  describe PoiseApplicationRuby::RubyMixin::Resource do
    resource(:poise_test) do
      include Poise(parent: :application)
      include described_class
    end
    subject { resource(:poise_test).new(nil, chef_run.run_context) }

    it { is_expected.to respond_to(:parent_ruby) }
  end # /describe PoiseApplicationRuby::RubyMixin::Resource

  describe PoiseApplicationRuby::RubyMixin::Provider do
    let(:app_state) { Hash.new }
    let(:parent) { double('parent', app_state: app_state) }
    let(:parent_ruby) { nil }
    let(:new_resource) { double('new_resource', parent: parent, parent_ruby: parent_ruby) }
    provider(:poise_test) do
      include described_class
    end
    subject(:test_provider) { provider(:poise_test).new(new_resource, chef_run.run_context) }

    describe '#ruby_mixin_command' do
      let(:command) { }
      subject { test_provider.send(:ruby_mixin_command, command) }

      context 'with no parent' do
        let(:parent) { nil }

        context 'with an array' do
          let(:command) { %w{myapp --serve} }
          it { is_expected.to eq %w{myapp --serve} }
        end # /context with an array

        context 'with a string' do
          let(:command) { 'myapp --serve' }
          it { is_expected.to eq 'myapp --serve' }
        end # /context with a string
      end # /context with no parent

      context 'with a gemfile' do
        let(:app_state) { {bundler_binary: '/test/bundle', bundler_gemfile: '/test/Gemfile'} }

        context 'with an array' do
          let(:command) { %w{myapp --serve} }
          it { is_expected.to eq %w{/test/bundle exec myapp --serve} }
        end # /context with an array

        context 'with a string' do
          let(:command) { 'myapp --serve' }
          it { is_expected.to eq '/test/bundle exec myapp --serve' }
        end # /context with a string
      end # /context with a gemfile

      context 'with a ruby_runtime' do
        let(:parent_ruby) { double('parent_ruby', gem_binary: '/test/gem') }
        before do
          expect(test_provider).to receive(:ruby_gem_bindir).and_return('/test')
        end

        context 'with an array' do
          let(:command) { %w{myapp --serve} }
          it { is_expected.to eq %w{/test/myapp --serve} }
        end # /context with an array

        context 'with a string' do
          let(:command) { 'myapp --serve' }
          it { is_expected.to eq '/test/myapp --serve' }
        end # /context with a string
      end # /context with a ruby_runtime
    end # /describe #ruby_mixin_command

    describe '#service_options' do
      let(:command) { 'myapp --serve' }
      let(:service_resource) { double('service_resource', command: command, environment: {}) }

      context 'with no parent' do
        let(:parent) { nil }
        it do
          test_provider.send(:service_options, service_resource)
          expect(service_resource).to receive(:command).with('myapp --serve')
          service_resource.command(command)
        end
      end # /context with no parent

      context 'with a gemfile' do
        let(:app_state) { {bundler_binary: '/test/bundle', bundler_gemfile: '/test/Gemfile'} }
        it do
          test_provider.send(:service_options, service_resource)
          expect(service_resource).to receive(:command).with('/test/bundle exec myapp --serve')
          service_resource.command(command)
        end
      end # /context with a gemfile
    end # /describe #service_options
  end # /describe PoiseApplicationRuby::RubyMixin::Provider
end
