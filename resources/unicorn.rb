#
# Author:: Noah Kantrowitz <noah@opscode.com>
# Cookbook Name:: application_ruby
# Resource:: unicorn
#
# Copyright:: 2011-2012, Opscode, Inc <legal@opscode.com>
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

attribute :preload_app, :kind_of => [TrueClass, FalseClass], :default => false
attribute :worker_processes, :kind_of => Integer, :default => [node.fetch('cpu', {}).fetch('total', 1).to_i * 4, 8].min
attribute :before_fork, :kind_of => String, :default => 'sleep 1'
attribute :after_fork, :kind_of => [String, NilClass], :default => nil
attribute :port, :kind_of => String, :default => "8080"
attribute :worker_timeout, :kind_of => Integer, :default => 60
attribute :bundler, :kind_of => [TrueClass, FalseClass, NilClass], :default => nil
attribute :bundle_command, :kind_of => [String, NilClass], :default => nil
attribute :listen, :kind_of => [Hash, NilClass], :default => nil
attribute :forked_user, :kind_of => [String, NilClass], :default => nil
attribute :forked_group, :kind_of => [String, NilClass], :default => nil
attribute :before_exec, :kind_of => [String, NilClass], :default => nil
attribute :pid, :kind_of => [String, NilClass], :default => nil
attribute :stderr_path, :kind_of => [String, NilClass], :default => nil
attribute :stdout_path, :kind_of => [String, NilClass], :default => nil
attribute :unicorn_command_line, :kind_of => [String, NilClass], :default => nil
attribute :copy_on_write, :kind_of => [TrueClass, FalseClass], :default => false
attribute :enable_stats, :kind_of => [TrueClass, FalseClass], :default => false

def options(*args, &block)
  @options ||= Mash[:tcp_nodelay => true, :backlog => 100]
  @options.update(options_block(*args, &block))
end
