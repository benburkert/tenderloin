module Tenderloin
  module Actions
    module VM
      class Reload < Base
        def prepare
          steps = [SharedFolders, Boot]
          steps.unshift(Halt) if @runner.fusion_vm.running?
          steps << Provision if Tenderloin.config.provisioning.enabled

          steps.each do |action_klass|
            @runner.add_action(action_klass)
          end
        end
      end
    end
  end
end
