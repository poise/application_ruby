#
# Author:: Louis Alridge <louis@hiplogiq.com>
# Cookbook Name:: application_ruby
# Provider:: nginx
#
# Copyright 2014, Hiplogiq
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

include Chef::DSL::IncludeRecipe

action :before_compile do

  include_recipe "nginx"

  node.set['nginx']['worker_processes'] = new_resource.worker_processes

  unless new_resource.server_aliases
    server_aliases = [ "#{new_resource.application.name}" ]
    if node.has_key?("cloud")
      server_aliases << node['cloud']['public_hostname']
    end
    new_resource.server_aliases server_aliases
  end

end

action :before_deploy do

  new_resource = @new_resource

  template "/etc/nginx/sites-available/#{ new_resource.application.name }" do
    source "base_sites_available.erb"
    owner  'root'
    group  node['root_group']
    mode   '0644'
    cookbook 'application_ruby'
    variables(
      server_aliases: new_resource.server_aliases,
      name:           new_resource.name,
      path:           new_resource.path,
      log_dir:        node['nginx']['log_dir'],
      server_socket_type: new_resource.server_socket_type
    )
    if ::File.exists?("#{node['nginx']['dir']}/sites-enabled/#{ new_resource.application.name }")
      notifies :reload, 'service[nginx]'
    end
  end

  execute 'ln-/etc/nginx/sites-enabled' do
    command "ln -fs /#{ node['nginx']['dir'] }/sites-available/#{ new_resource.application.name } /#{ node['nginx']['dir'] }/sites-enabled/#{ new_resource.application.name }"
    only_if { ::File.exists?("#{ node['nginx']['dir']}/sites-available/#{ new_resource.application.name }")}
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
