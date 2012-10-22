module Fog
  module Compute
    class Tenderloin
      class Real

        def get_vm(id)
          request(['jsondump', '-f', id], true)
        end

      end
    end
  end
end
