require "helper"

# TODO - Global vars are so bad. Do this better.

describe "VMRequests" do
  describe "ListRequest" do
    it "lists available vms" do
      res = get_compute.list_vms
      res.should_not be_empty
    end
  end
end
