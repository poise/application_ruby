#
# Cookbook Name:: application_ruby
# Resources:: passenger
#
# Copyright 2012, ZephirWorks
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

attribute :server_aliases, :kind_of => [Array, NilClass], :default => nil
# Actually defaults to "#{application.name}.conf.erb", but nil means it wasn't set by the user
attribute :webapp_template, :kind_of => [String, NilClass], :default => nil
attribute :params, :kind_of => [Hash, NilClass], :default => nil
