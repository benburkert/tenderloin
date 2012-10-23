# fog-tenderloin

Implementation of Tenderloin for Fog.

## Usage

This will treat a collection of loin definition files as a fog server collection, allowing you to start/stop/SSH in to them.

The default search pattern is `**/*.loin`, this can be configured when you create instantiate the instance.

      Fog::Compute.new(:provider => "Tenderloin", :loinfile_glob => '**/*.loin', :loin_cmd => 'loin')

The loin\_cmd and loinfile\_glob parameters are optional - the defaults are shown above.

You can then manipulate this as per usual for fog

    compute.servers.first.start
    compute.servers.first.ssh("ls /")
    compute.servers.first.stop
