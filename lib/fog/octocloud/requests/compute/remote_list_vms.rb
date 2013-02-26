module Fog
  module Compute
    class Octocloud
      class Real

        def remote_list_vms()
          remote_request(:method => :get, :expects => [200], :path => "/api/virtual-machines" )
        end

      end
    end
  end
end
