module Tenderloin
  module Actions
    module VM
      class Export < Base
        attr_reader :temp_dir

        def execute!
          setup_temp_dir
          export
        end

        def cleanup
          if temp_dir
            logger.info "Removing temporary export directory..."
            FileUtils.rm_r(temp_dir)
          end
        end

        def rescue(exception)
          cleanup
        end

        def setup_temp_dir
          @temp_dir = File.join(Env.tmp_path, Time.now.to_i.to_s)

          logger.info "Creating temporary directory for export..."
          FileUtils.mkpath(temp_dir)
        end

        def ovf_path
          File.join(temp_dir, Tenderloin.config.vm.box_ovf)
        end

        def export
          logger.info "Exporting VM to #{ovf_path} ..."
          @runner.vm.export(ovf_path, {}, true)
        end
      end
    end
  end
end
