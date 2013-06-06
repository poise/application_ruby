#
# Cookbook Name:: application_ruby
# Provider:: memcached
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

action :before_compile do

  new_resource.symlink_before_migrate.update({"memcached.yml" => "config/memcached.yml"})

end

action :before_deploy do

  results = search(:node, "role:#{new_resource.role} AND chef_environment:#{node.chef_environment} NOT hostname:#{node['hostname']}")
  if results.length == 0
    if node['roles'].include?(new_resource.role)
      results << node
    end
  end
  Chef::Log.warn("No node with role #{new_resource.role}") unless results.any?

  template "#{new_resource.application.path}/shared/memcached.yml" do
    source new_resource.memcached_template || "memcached.yml.erb"
    cookbook new_resource.memcached_template ? new_resource.cookbook_name.to_s : "application_ruby"
    owner new_resource.owner
    group new_resource.group
    mode "644"
    variables.update(
      :env => new_resource.environment_name,
      :hosts => results.sort_by { |r| r.name },
      :options => new_resource.options
    )
  end

end

action :before_migrate do
end

action :before_symlink do
end

action :before_restart do
end

action :after_restart do
end
