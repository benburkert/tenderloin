require 'fog-tenderloin'

FOG_MOCK = ENV['FOG_MOCK'] || false

def get_compute
  Fog::Compute.new(:provider => "Tenderloin")
end
