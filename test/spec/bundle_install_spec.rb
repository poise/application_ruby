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
    recipe do
      bundle_install '/test/Gemfile'
    end
    before do
      allow_any_instance_of(described_class).to receive(:which).with('gem').and_return('/test/bin/gem')
    end

    it { is_expected.to install_bundle_install('/test/Gemfile').with(gem_binary: '/test/bin/gem', absolute_gem_binary: '/test/bin/gem') }

    # Just testing this for coverage of the update_bundle_install matcher
    context 'with action :update' do
      recipe do
        bundle_install '/test/Gemfile' do
          action :update
        end
      end

        it { is_expected.to update_bundle_install('/test/Gemfile') }
    end # /context with action :update
  end # /describe PoiseApplicationRuby::Resources::BundleInstall::Resource

  describe PoiseApplicationRuby::Resources::BundleInstall::Provider do
    let(:new_resource) { double() }
    let(:provider) { described_class.new(new_resource, nil) }

    describe '#action_install' do
      it do
        expect(provider).to receive(:install_bundler)
        expect(provider).to receive(:run_bundler).with('install')
        expect(provider).to receive(:set_state)
        provider.action_install
      end
    end # /describe #action_install

    describe '#action_update' do
      it do
        expect(provider).to receive(:install_bundler)
        expect(provider).to receive(:run_bundler).with('update')
        expect(provider).to receive(:set_state)
        provider.action_update
      end
    end # /describe #action_update

    describe '#install_bundler' do
      subject { provider.send(:install_bundler) }
      before do
        allow(Chef::Resource::GemPackage).to receive(:new).and_wrap_original do |m, *args|
          m.call(*args).tap do |r|
            expect(r).to receive(:run_action)
          end
        end
      end

      context 'with defaults' do
        let(:new_resource) { double(bundler_version: nil, absolute_gem_binary: 'gem') }
        its(:action) { is_expected.to eq %i{upgrade} }
        its(:version) { is_expected.to be_nil }
        its(:gem_binary) { is_expected.to eq 'gem' }
      end # /context with defaults

      context 'with a specific version' do
        let(:new_resource) { double(bundler_version: '1.0', absolute_gem_binary: 'gem') }
        its(:action) { is_expected.to eq :install }
        its(:version) { is_expected.to eq '1.0' }
        its(:gem_binary) { is_expected.to eq 'gem' }
      end # /context with a specific version
    end # /describe #install_bundler

    describe '#run_bundler' do
      let(:bundle_output) { '' }
      subject { provider.send(:run_bundler, nil) }
      before do
        allow(provider).to receive(:bundler_command).and_return(%w{bundle install})
        allow(provider).to receive(:gemfile_path).and_return('Gemfile')
        expect(provider).to receive(:shell_out!).with(%w{bundle install}, environment: {'BUNDLE_GEMFILE' => 'Gemfile'}).and_return(double(stdout: bundle_output))
      end

      context 'with a new gem' do
        let(:bundle_output) { <<-EOH }
Fetching gem metadata from https://rubygems.org/.......
Fetching version metadata from https://rubygems.org/...
Fetching dependency metadata from https://rubygems.org/..
Resolving dependencies...
Using rake 10.4.2
Using addressable 2.3.7
Installing launchy 2.4.3
Using poise 1.1.0 from source at /Users/coderanger/src/poise
Using poise-application 5.0.0 from source at /Users/coderanger/src/application
Using poise-service 1.0.0 from source at /Users/coderanger/src/poise-service
Using poise-application-ruby 4.0.0 from source at .
Using yard-classmethods 1.0 from source at /Users/coderanger/src/yard-classmethods
Using poise-boiler 1.0.0 from source at /Users/coderanger/src/poise-boiler
Bundle complete! 7 Gemfile dependencies, 115 gems now installed.
Use `bundle show [gemname]` to see where a bundled gem is installed.
EOH
        it do
          expect(new_resource).to receive(:updated_by_last_action).with(true)
          subject
        end
      end # /context with a new gem

      context 'with existing gems' do
        let(:bundle_output) { <<-EOH }
Fetching gem metadata from https://rubygems.org/.......
Fetching version metadata from https://rubygems.org/...
Fetching dependency metadata from https://rubygems.org/..
Resolving dependencies...
Using rake 10.4.2
Using addressable 2.3.7
Using launchy 2.4.3
Using poise 1.1.0 from source at /Users/coderanger/src/poise
Using poise-application 5.0.0 from source at /Users/coderanger/src/application
Using poise-service 1.0.0 from source at /Users/coderanger/src/poise-service
Using poise-application-ruby 4.0.0 from source at .
Using yard-classmethods 1.0 from source at /Users/coderanger/src/yard-classmethods
Using poise-boiler 1.0.0 from source at /Users/coderanger/src/poise-boiler
Bundle complete! 7 Gemfile dependencies, 115 gems now installed.
Use `bundle show [gemname]` to see where a bundled gem is installed.
EOH
        # No-op to ensure #updated_by_last_action is not called.
        it { subject }
      end # /context with existing gems
    end # /describe #run_bundler

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
        it { is_expected.to eq %w{--path=vendor/bundle} }
      end # /context with vendor

      context 'with vendor in a path' do
        let(:options) { {vendor: 'vendor'} }
        it { is_expected.to eq %w{--path=vendor} }
      end # /context with vendor in a path

      context 'with several options' do
        let(:options) { {deployment: true, binstubs: 'bin', without: %w{test development}} }
        it { is_expected.to eq %w{--binstubs=bin --deployment --without test development} }
      end # /context with several options
    end # /describe #bundler_options

    describe '#bundler_command' do
      let(:action) { '' }
      subject { provider.send(:bundler_command, action) }
      before do
        allow(provider).to receive(:gem_bindir).and_return('/test')
        allow(provider).to receive(:bundler_options).and_return(%w{--binstubs --deployment})
      end

      context 'with action install' do
        let(:action) { 'install' }
        it { is_expected.to eq %w{/test/bundle install --binstubs --deployment} }
      end # /context with action install

      context 'with action update' do
        let(:action) { 'update' }
        it { is_expected.to eq %w{/test/bundle update --binstubs --deployment} }
      end # /context with action update
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
