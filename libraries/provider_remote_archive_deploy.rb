
require 'chef/provider/remote_file'

class Chef
  class Provider
    class RemoteArchive
      class Deploy < Chef::Provider::RemoteFile

        def initialize(new_resource, run_context)
          @deploy_resource = new_resource
          @new_resource = Chef::Resource::RemoteFile.new(@deploy_resource.name)

          @new_resource.source @deploy_resource.repository
          @new_resource.path ::File.join(@deploy_resource.destination, ::File.basename(@deploy_resource.repository))
          unless @deploy_resource.revision == "HEAD"
            @new_resource.checksum @deploy_resource.revision
          end

          @new_resource.owner @deploy_resource.user
          @new_resource.group @deploy_resource.group
          @action = action
          @current_resource = nil
          @run_context = run_context
          @converge_actions = nil
        end

        def revision_slug
          # Use the remote file's checksum for the revision_slug
          # If for some reason the checksum hasn't been set yet,
          # make sure the file has been downloaded.
          unless @new_resource.checksum
            action_sync
          end
          @revision_slug ||= @new_resource.checksum
        end

        def action_sync
          create_dir_unless_exists(@deploy_resource.destination)
          purge_old_downloads
          action_create
          extract_files(@new_resource.path, @deploy_resource.destination)
        end

        private

        def create_dir_unless_exists(dir)
          if ::File.directory?(dir)
            Chef::Log.debug "#{@new_resource} not creating #{dir} because it already exists"
            return
          end
          converge_by("create new directory #{dir}") do
            begin
              FileUtils.mkdir_p(dir)
              Chef::Log.debug "#{@new_resource} created directory #{dir}"
              if @new_resource.user
                FileUtils.chown(@new_resource.user, nil, dir)
                Chef::Log.debug("#{@new_resource} set user to #{@new_resource.user} for #{dir}")
              end
              if @new_resource.group
                FileUtils.chown(nil, @new_resource.group, dir)
                Chef::Log.debug("#{@new_resource} set group to #{@new_resource.group} for #{dir}")
              end
            rescue => e
              raise Chef::Exceptions::FileNotFound.new("Cannot create directory #{dir}: #{e.message}")
            end
          end
        end

        def purge_old_downloads
          converge_by("purge old downloads") do
            Dir.glob( "#{@deploy_resource.destination}/*" ).each do |direntry|
              FileUtils.rm_rf( direntry ) unless direntry == @new_resource.path
              Chef::Log.info("#{@new_resource} purged old download #{direntry}")
            end
          end
        end

        def extract_files(path, destination)
          converge_by("extract archived files") do
            shell_out!("tar zxf #{path} -C #{destination} --strip-components=1")
          end
        end

      end
    end
  end
end
