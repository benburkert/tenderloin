module Tenderloin
  # Represents a "box," which is simply a packaged tenderloin environment.
  # Boxes are simply `tar` files which contain an exported VirtualBox
  # virtual machine, at the least. They are created with `tenderloin package`
  # and may contain additional files if specified by the creator. This
  # class serves to help manage these boxes, although most of the logic
  # is kicked out to actions.
  #
  # What can the {Box} class do?
  #
  # * Find boxes
  # * Add existing boxes (from some URI)
  # * Delete existing boxes
  #
  # # Finding Boxes
  #
  # Using the {Box.find} method, you can search for existing boxes. This
  # method will return `nil` if none is found or an instance of {Box}
  # otherwise.
  #
  #     box = Tenderloin::Box.find("base")
  #     if box.nil?
  #       puts "Box not found!"
  #     else
  #       puts "Box exists at #{box.directory}"
  #     end
  #
  # # Adding a Box
  #
  # Boxes can be added from any URI. Some schemas aren't supported; if this
  # is the case, the error will output to the logger.
  #
  #     Tenderloin::Box.add("foo", "http://myfiles.com/foo.box")
  #
  # # Destroying a box
  #
  # Boxes can be deleted as well. This method is _final_ and there is no way
  # to undo this action once it is completed.
  #
  #     box = Tenderloin::Box.find("foo")
  #     box.destroy
  #
  class Box < Actions::Runner
    # The name of the box.
    attr_accessor :name

    # The URI for a new box. This is not available for existing boxes.
    attr_accessor :uri

    # The temporary path to the downloaded or copied box. This should
    # only be used internally.
    attr_accessor :temp_path

    class <<self
      # Returns an array of all created boxes, as strings.
      #
      # @return [Array<String>]
      def all
        results = []

        Dir.open(Env.boxes_path) do |dir|
          dir.each do |d|
            next if d == "." || d == ".." || !File.directory?(File.join(Env.boxes_path, d))
            results << d.to_s
          end
        end

        results
      end

      # Finds a box with the given name. This method searches for a box
      # with the given name, returning `nil` if none is found or returning
      # a {Box} instance otherwise.
      #
      # @param [String] name The name of the box
      # @return [Box] Instance of {Box} representing the box found
      def find(name)
        return nil unless File.directory?(directory(name))
        new(name)
      end

      # Adds a new box with given name from the given URI. This method
      # begins the process of adding a box from a given URI by setting up
      # the {Box} instance and calling {#add}.
      #
      # @param [String] name The name of the box
      # @param [String] uri URI to the box file
      def add(name, uri)
        box = new
        box.name = name
        box.uri = uri
        box.add
      end

      # Returns the directory to a box of the given name. The name given
      # as a parameter is not checked for existence; this method simply
      # returns the directory which would be used if the box did exist.
      #
      # @param [String] name Name of the box whose directory you're interested in.
      # @return [String] Full path to the box directory.
      def directory(name)
        File.join(Env.boxes_path, name)
      end
    end

    # Creates a new box instance. Given an optional `name` parameter,
    # newly created instance will have that name, otherwise it defaults
    # to `nil`.
    #
    # **Note:** This method does not actually _create_ the box, but merely
    # returns a new, abstract representation of it. To add a box, see {#add}.
    def initialize(name=nil)
      @name = name
    end

    # Returns path to the vmx file of the box. This contains the config
    #
    # @return [String]
    def vmx_file
      File.join(directory, Tenderloin.config.vm.box_vmx)
    end

    # Begins the process of adding a box to the tenderloin installation. This
    # method requires that `name` and `uri` be set. The logic of this method
    # is kicked out to the {Actions::Box::Add add box} action.
    def add
      execute!(Actions::Box::Add)
    end

    # Beings the process of destroying this box.
    def destroy
      execute!(Actions::Box::Destroy)
    end

    # Returns the directory to the location of this boxes content in the local
    # filesystem.
    #
    # @return [String]
    def directory
      self.class.directory(self.name)
    end
  end
end
