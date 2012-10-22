require "helper"

# TODO - Global vars are so bad. Do this better.

describe "VMRequests" do
  describe "ListRequest" do
    it "lists available vms" do
      res = get_compute.list_vms
      res.should_not be_empty
    end

    it "loads VM info" do
      vm = get_compute.list_vms.first
      res = get_compute.get_vm(vm)
      res.should_not be_empty
      res.should be_kind_of Hash
    end

  end
end
