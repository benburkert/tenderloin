module Tenderloin
  module Actions
    module VM
      class Boot < Base
        def execute!
          @runner.invoke_around_callback(:boot) do
            # Startup the VM
            boot

            # Wait for it to complete booting, or error if we could
            # never detect it booted up successfully
            if !wait_for_boot
              error_and_exit(<<-error)
Failed to connect to VM! Failed to boot?
error
            end
          end
        end

        def collect_shared_folders
          # The root shared folder for the project
          ["tenderloin-root", Env.root_path, Tenderloin.config.vm.project_directory]
        end

        def boot
          logger.info "Booting VM..."

          @runner.fusion_vm.start(:headless => true)
        end

        def wait_for_boot(sleeptime=5)
          logger.info "Waiting for VM to boot..."

          Tenderloin.config[:ssh][:max_tries].to_i.times do |i|
            logger.info "Trying to connect (attempt ##{i+1} of #{Tenderloin.config[:ssh][:max_tries]})..."
            ip = @runner.fusion_vm.ip

            if ip && Tenderloin::SSH.up?(ip)
              logger.info "VM booted and ready for use on IP: " + ip
              return true
            end

            sleep sleeptime
          end

          logger.info "Failed to connect to VM! Failed to boot?"
          false
        end
      end
    end
  end
end
