#
# Author:: Louis Alridge <louis@hiplogiq.com>
# Cookbook Name:: application_ruby
# Resource:: puma
#
# Copyright:: 2014, Hiplogiq
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include ApplicationCookbook::ResourceBase

attribute :app_path, :kind_of => String
attribute :preload_app, :kind_of => [TrueClass, FalseClass], :default => false
attribute :workers, :kind_of => Integer, :default => [node.fetch('cpu', {}).fetch('total', 1).to_i * 4, 8].min
attribute :owner, :kind_of => String, :default => "deploy"
attribute :bind, :kind_of => [String, NilClass], :default => nil
attribute :bundler, :kind_of => [TrueClass, FalseClass, NilClass], :default => nil
attribute :bundle_command, :kind_of => [String, NilClass], :default => nil
attribute :pid, :kind_of =>  [String, NilClass], :default => nil
attribute :stderr_redirect, :kind_of => [String, NilClass], :default => nil
attribute :stdout_redirect, :kind_of => [String, NilClass], :default => nil
attribute :on_worker_boot, :kind_of => [String, NilClass], :default => nil
attribute :upstart, :kind_of => [TrueClass, FalseClass], :default => false
attribute :logrotate, :kind_of => [TrueClass, FalseClass], :default => false

#def options(*args, &block)
#  @options ||= Mash[:tcp_nodelay => true, :backlog => 100]
#  @options.update(options_block(*args, &block))
#end
