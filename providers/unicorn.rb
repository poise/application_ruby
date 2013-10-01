#
# Author:: Noah Kantrowitz <noah@opscode.com>
# Cookbook Name:: application_ruby
# Provider:: unicorn
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

include Chef::Mixin::LanguageIncludeRecipe

action :before_compile do

  if new_resource.bundler.nil?
    new_resource.bundler rails_resource && rails_resource.bundler
  end

  unless new_resource.bundler
    include_recipe "unicorn"
  end

  new_resource.bundle_command rails_resource && rails_resource.bundle_command

  unless new_resource.restart_command
    new_resource.restart_command do
      execute "/etc/init.d/#{new_resource.name} hup" do
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

  unicorn_config "/etc/unicorn/#{new_resource.name}.rb" do
    listen(new_resource.listen || { new_resource.port => new_resource.options })
    working_directory ::File.join(new_resource.path, 'current')
    worker_timeout new_resource.worker_timeout
    preload_app new_resource.preload_app
    worker_processes new_resource.worker_processes
    before_fork new_resource.before_fork
    after_fork new_resource.after_fork
    forked_user new_resource.forked_user
    forked_group new_resource.forked_group
    before_exec new_resource.before_exec
    pid new_resource.pid
    stderr_path new_resource.stderr_path
    stdout_path new_resource.stdout_path
    unicorn_command_line new_resource.unicorn_command_line
    copy_on_write new_resource.copy_on_write
    enable_stats new_resource.enable_stats
  end

  runit_service new_resource.name do
    run_template_name 'unicorn'
    log_template_name 'unicorn'
    owner new_resource.owner if new_resource.owner
    group new_resource.group if new_resource.group

    cookbook 'application_ruby'
    options(
      :app => new_resource,
      :bundler => new_resource.bundler,
      :bundle_command => new_resource.bundle_command,
      :rails_env => new_resource.environment_name,
      :smells_like_rack => ::File.exists?(::File.join(new_resource.path, "current", "config.ru"))
    )
  end

end

action :after_restart do
end

protected

def rails_resource
  new_resource.application.sub_resources.select{|res| res.type == :rails}.first
end
