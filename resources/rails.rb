#
# Author:: Noah Kantrowitz <noah@opscode.com>
# Cookbook Name:: application_ruby
# Resource:: rails
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

include Chef::Resource::ApplicationBase

attribute :database_master_role, :kind_of => [String, NilClass], :default => nil
# Actually defaults to "database.yml.erb", but nil means it wasn't set by the user
attribute :database_template, :kind_of => [String, NilClass], :default => nil
attribute :gems, :kind_of => [Array, Hash], :default => []
attribute :bundler, :kind_of => [NilClass, TrueClass, FalseClass], :default => nil
attribute :bundler_deployment, :kind_of => [NilClass, TrueClass, FalseClass], :default => nil
attribute :bundler_without_groups, :kind_of => [Array], :default => []
attribute :bundle_command, :kind_of => [String, NilClass], :default => "bundle"
attribute :precompile_assets, :kind_of => [NilClass, TrueClass, FalseClass], :default => nil

def database(*args, &block)
  @database ||= Mash.new
  @database.update(options_block(*args, &block))
end
