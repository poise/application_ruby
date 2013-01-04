#
# Cookbook Name:: application_ruby
# Provider:: passenger
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

include Chef::Mixin::LanguageIncludeRecipe

action :before_compile do

  include_recipe "apache2"
  include_recipe "apache2::mod_ssl"
  include_recipe "apache2::mod_rewrite"
  include_recipe "passenger_apache2::mod_rails"

  unless new_resource.server_aliases
    server_aliases = [ "#{new_resource.application.name}.#{node['domain']}", node['fqdn'] ]
    if node.has_key?("cloud")
      server_aliases << node['cloud']['public_hostname']
    end
    new_resource.server_aliases server_aliases
  end

  new_resource.restart_command "touch #{new_resource.application.path}/current/tmp/restart.txt" unless new_resource.restart_command
end

action :before_deploy do

  new_resource = @new_resource

  web_app new_resource.application.name do
    docroot "#{new_resource.application.path}/current/public"
    template new_resource.webapp_template || "#{new_resource.application.name}.conf.erb"
    cookbook new_resource.cookbook_name.to_s
    server_name "#{new_resource.application.name}.#{node['domain']}"
    server_aliases new_resource.server_aliases
    log_dir node['apache']['log_dir']
    rails_env new_resource.application.environment_name
    extra new_resource.params
  end

  apache_site "000-default" do
    enable false
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
