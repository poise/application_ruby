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
require 'poise_application_ruby/resources/bundle_install'
require 'poise_application_ruby/error'

describe PoiseApplicationRuby::Resources::BundleInstall do
  describe PoiseApplicationRuby::Resources::BundleInstall::Resource do
  end # /describe PoiseApplicationRuby::Resources::BundleInstall::Resource

  describe PoiseApplicationRuby::Resources::BundleInstall::Provider do
    let(:new_resource) { double() }
    let(:provider) { described_class.new(new_resource, nil) }
    subject { provider }

    describe '#gem_bin' do
      let(:new_resource) { double(absolute_gem_binary: '/usr/local/bin/gem') }
      let(:gem_environment) { '' }
      subject { provider.send(:gem_bindir) }
      before do
        expect(provider).to receive(:shell_out!).with(['/usr/local/bin/gem', 'environment']).and_return(double(stdout: gem_environment))
      end

      context 'with an Ubuntu 14.04 gem environment' do
        let(:gem_environment) { <<-EOH }
RubyGems Environment:
  - RUBYGEMS VERSION: 1.8.23
  - RUBY VERSION: 1.9.3 (2013-11-22 patchlevel 484) [x86_64-linux]
  - INSTALLATION DIRECTORY: /var/lib/gems/1.9.1
  - RUBY EXECUTABLE: /usr/bin/ruby1.9.1
  - EXECUTABLE DIRECTORY: /usr/local/bin
  - RUBYGEMS PLATFORMS:
    - ruby
    - x86_64-linux
  - GEM PATHS:
     - /var/lib/gems/1.9.1
     - /root/.gem/ruby/1.9.1
  - GEM CONFIGURATION:
     - :update_sources => true
     - :verbose => true
     - :benchmark => false
     - :backtrace => false
     - :bulk_threshold => 1000
  - REMOTE SOURCES:
     - http://rubygems.org/
EOH
        it { is_expected.to eq '/usr/local/bin' }
      end # /context Ubuntu 14.04 gem environment

      context 'with an rbenv gem environment' do
        let(:gem_environment) { <<-EOH }
RubyGems Environment:
  - RUBYGEMS VERSION: 2.2.2
  - RUBY VERSION: 2.1.2 (2014-05-08 patchlevel 95) [x86_64-darwin13.0]
  - INSTALLATION DIRECTORY: /Users/asmithee/.rbenv/versions/2.1.2/lib/ruby/gems/2.1.0
  - RUBY EXECUTABLE: /Users/asmithee/.rbenv/versions/2.1.2/bin/ruby
  - EXECUTABLE DIRECTORY: /Users/asmithee/.rbenv/versions/2.1.2/bin
  - SPEC CACHE DIRECTORY: /Users/asmithee/.gem/specs
  - RUBYGEMS PLATFORMS:
    - ruby
    - x86_64-darwin-13
  - GEM PATHS:
     - /Users/asmithee/.rbenv/versions/2.1.2/lib/ruby/gems/2.1.0
     - /Users/asmithee/.gem/ruby/2.1.0
  - GEM CONFIGURATION:
     - :update_sources => true
     - :verbose => true
     - :backtrace => false
     - :bulk_threshold => 1000
     - "gem" => "--no-ri --no-rdoc"
  - REMOTE SOURCES:
     - https://rubygems.org/
  - SHELL PATH:
     - /Users/asmithee/.rbenv/versions/2.1.2/bin
     - /usr/local/opt/rbenv/libexec
     - /Users/asmithee/.rbenv/shims
     - /usr/local/opt/rbenv/bin
     - /opt/vagrant/bin
     - /Users/asmithee/.rbcompile/bin
     - /usr/local/share/npm/bin
     - /usr/local/share/python
     - /usr/local/bin
     - /usr/bin
     - /bin
     - /usr/sbin
     - /sbin
     - /usr/local/bin
     - /usr/local/MacGPG2/bin
     - /usr/texbin
EOH
        it { is_expected.to eq '/Users/asmithee/.rbenv/versions/2.1.2/bin' }
      end # /context rbenv gem environment

      context 'with no executable directory' do
        it { expect { subject }.to raise_error(PoiseApplicationRuby::Error) }
      end # /context with no executable directory
    end # /describe #gem_bin

    describe '#bundler_options' do
      let(:default_options) { %i{binstubs deployment without jobs retry vendor}.inject({}) {|memo, v| memo[v] = nil; memo } }
      let(:options) { {} }
      let(:new_resource) { double(default_options.merge(options)) }
      subject { provider.send(:bundler_options) }

      context 'with binstubs' do
        let(:options) { {binstubs: true} }
        it { is_expected.to eq %w{--binstubs} }
      end # /context with binstubs

      context 'with binstubs in a path' do
        let(:options) { {binstubs: 'bin'} }
        it { is_expected.to eq %w{--binstubs=bin} }
      end # /context with binstubs in a path

      context 'with deployment' do
        let(:options) { {deployment: true} }
        it { is_expected.to eq %w{--deployment} }
      end # /context with deployment

      context 'with without groups' do
        let(:options) { {without: %w{development test}} }
        it { is_expected.to eq %w{--without development test} }
      end # /context with without groups

      context 'with jobs' do
        let(:options) { {jobs: 3} }
        it { is_expected.to eq %w{--jobs=3} }
      end # /context with jobs

      context 'with retry' do
        let(:options) { {retry: 3} }
        it { is_expected.to eq %w{--retry=3} }
      end # /context with jobs

      context 'with vendor' do
        let(:options) { {vendor: true} }
        it { is_expected.to eq %w{--vendor} }
      end # /context with vendor

      context 'with vendor in a path' do
        let(:options) { {vendor: 'vendor'} }
        it { is_expected.to eq %w{--vendor=vendor} }
      end # /context with vendor in a path

      context 'with several options' do
        let(:options) { {deployment: true, binstubs: 'bin', without: %w{test development}} }
        it { is_expected.to eq %w{--binstubs=bin --deployment --without test development} }
      end # /context with several options
    end # /describe #bundler_options

    describe '#bundler_command' do
      subject { provider.send(:bundler_command) }
      before do
        allow(provider).to receive(:gem_bindir).and_return('/test')
        allow(provider).to receive(:bundler_options).and_return(%w{--binstubs --deployment})
      end
      it { is_expected.to eq %w{/test/bundle install --binstubs --deployment} }
    end # /describe #bundler_command

    describe '#gemfile_path' do
      let(:path) { '' }
      let(:files) { [] }
      let(:new_resource) { double(path: path) }
      subject { provider.send(:gemfile_path) }
      before do
        allow(File).to receive(:file?).and_return(false)
        files.each do |file|
          allow(File).to receive(:file?).with(file).and_return(true)
        end
      end

      context 'with a simple file' do
        let(:path) { '/test/Gemfile' }
        let(:files) { %w{/test/Gemfile} }
        it { is_expected.to eq '/test/Gemfile' }
      end # /context with a simple file

      context 'with a folder' do
        let(:path) { '/test' }
        let(:files) { %w{/test/Gemfile} }
        it { is_expected.to eq '/test/Gemfile' }
      end # /context with a folder

      context 'with a parent folder' do
        let(:path) { '/test/inner' }
        let(:files) { %w{/test/Gemfile} }
        it { is_expected.to eq '/test/Gemfile' }
      end # /context with a parent folder

      context 'with no Gemfile' do
        let(:path) { '/test/Gemfile' }
        it { is_expected.to be_nil }
      end # /context with no Gemfile
    end # /describe #gemfile_path
  end # /describe PoiseApplicationRuby::Resources::BundleInstall::Provider
end
