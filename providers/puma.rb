#
# Author:: Louis Alridge <louis@hiplogiq.com>
# Cookbook Name:: application_ruby
# Provider:: puma
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

include Chef::DSL::IncludeRecipe

action :before_compile do

  if new_resource.bundler.nil?
    new_resource.bundler rails_resource && rails_resource.bundler
  end

  unless new_resource.bundler
    include_recipe "puma"
  end

  new_resource.bundle_command rails_resource && rails_resource.bundle_command

  app_path = new_resource.app_path

  unless new_resource.restart_command
    new_resource.restart_command do
      execute "#{ app_path }/shared/puma/puma_start.sh || #{ app_path }/shared/puma/puma_restart.sh" do
        user "root"
      end
    end
  end

end

action :before_deploy do
end

action :before_migrate do
end

action :before_symlink do
end

action :before_restart do

  new_resource = @new_resource

  puma_config new_resource.name do
    directory ::File.join( new_resource.app_path) #root of the app (current / releases / repo / shared )
    working_dir ::File.join( new_resource.app_path, 'current')
    preload_app new_resource.preload_app
    bind new_resource.bind
    owner new_resource.owner

    environment node.chef_environment
    workers new_resource.workers

    pid new_resource.pid
    stderr_redirect new_resource.stderr_redirect
    stdout_redirect new_resource.stdout_redirect

    daemonize true
    upstart new_resource.upstart
    on_worker_boot new_resource.on_worker_boot
    monit !new_resource.upstart
    logrotate new_resource.logrotate
  end

  #puma-init scripts are created by puma cookbook already
  #runit_service new_resource.name do
  #  run_template_name 'puma'
  #  log_template_name 'puma'
  #  owner new_resource.owner if new_resource.owner
  #  group new_resource.group if new_resource.group
  #
  #  cookbook 'application_ruby'
  #  options(
  #    app: new_resource,
  #    bundler: new_resource.bundler,
  #    bundle_command: new_resource.bundle_command,
  #    rails_env: new_resource.environment_name,
  #    smells_like_rack: ::File.exists?(::File.join(new_resource.path, "current", "config.ru"))
  #  )
  #end

end

action :after_restart do
end

protected

def rails_resource
  new_resource.application.sub_resources.select{|res| res.type == :rails}.first
end
