module Tenderloin
  module Actions
    module Box
      # This action unpackages a downloaded box file into its final
      # box destination within the tenderloin home folder.
      class Unpackage < Base

        def execute!
          @runner.invoke_around_callback(:unpackage) do
            setup_box_dir
            decompress
          end
        end

        def rescue(exception)
          if File.directory?(box_dir)
            logger.info "An error occurred, rolling back box unpackaging..."
            FileUtils.rm_rf(box_dir)
          end
        end

        def setup_box_dir
          if File.directory?(box_dir)
            error_and_exit(<<-msg)
This box appears to already exist! Please call `tenderloin box remove #{@runner.name}`
and then try to add it again.
msg
          end

          FileUtils.mkdir_p(box_dir)
        end

        def box_dir
          @runner.directory
        end

        def decompress
          Dir.chdir(box_dir) do
            logger.info "Extracting box to #{box_dir}..."
            Archive::Tar::Minitar.unpack(@runner.temp_path, box_dir)
          end
        end
      end
    end
  end
end
