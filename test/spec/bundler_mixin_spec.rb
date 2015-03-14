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
require 'poise_application_ruby/bundler_mixin'


describe PoiseApplicationRuby::BundlerMixin do
  let(:app_state) { Hash.new }
  let(:new_resource) { double(parent: double(app_state: app_state)) }
  let(:helper) do
    Class.new do
      include PoiseApplicationRuby::BundlerMixin
      attr_reader :new_resource
      def initialize(res)
        @new_resource = res
      end
    end.new(new_resource)
  end

  describe '#bundle_exec_command' do
    let(:command) { }
    subject { helper.bundle_exec_command(command) }

    context 'with no parent' do
      let(:new_resource) { double(parent: nil) }

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
  end # /describe #bundle_exec_command

  describe '#bundle_exec_environment' do
    subject { helper.bundle_exec_environment }

    context 'with no parent' do
      let(:new_resource) { double(parent: nil) }
      it { is_expected.to eq Hash.new }
    end # /context with no parent

    context 'with a gemfile' do
      let(:app_state) { {bundler_binary: '/test/bundle', bundler_gemfile: '/test/Gemfile'} }
      it { is_expected.to eq({'BUNDLE_GEMFILE' => '/test/Gemfile'}) }
    end # /context with a gemfile
  end # /describe #bundle_exec_environment

  describe '#bundle_service_options' do
    let(:command) { 'myapp --serve' }
    let(:environment) { Hash.new }
    let(:service_resource) { double(command: command, environment: environment) }
    subject { helper.bundle_service_options(service_resource) }

    context 'with no parent' do
      let(:new_resource) { double(parent: nil) }
      it do
        expect(service_resource).to receive(:command).with('myapp --serve')
        subject
        expect(environment).to eq Hash.new
      end
    end # /context with no parent

    context 'with a gemfile' do
      let(:app_state) { {bundler_binary: '/test/bundle', bundler_gemfile: '/test/Gemfile'} }
      it do
        expect(service_resource).to receive(:command).with('/test/bundle exec myapp --serve')
        subject
        expect(environment).to eq({'BUNDLE_GEMFILE' => '/test/Gemfile'})
      end
    end # /context with a gemfile

    context 'without a command' do
      let(:app_state) { {bundler_binary: '/test/bundle', bundler_gemfile: '/test/Gemfile'} }
      let(:command) { nil }
      it do
        subject
        expect(environment).to eq({'BUNDLE_GEMFILE' => '/test/Gemfile'})
      end
    end # /context without a command
  end # /describe #bundle_service_options
end
