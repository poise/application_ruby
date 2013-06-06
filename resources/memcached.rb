#
# Cookbook Name:: application_ruby
# Resource:: memcached
#
# Copyright:: 2012, Opscode, Inc <legal@opscode.com>
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

attribute :role, :kind_of => [String, NilClass], :default => nil
# Actually defaults to "memcached.yml.erb", but nil means it wasn't set by the user
attribute :memcached_template, :kind_of => [String, NilClass], :default => nil

def options(*args, &block)
  @options ||= Mash.new
  @options.update(options_block(*args, &block))
end
