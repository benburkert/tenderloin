require File.join(File.dirname(__FILE__), '..', 'test_helper')

class VMTest < Test::Unit::TestCase
  setup do
    @mock_vm = mock("vm")
    mock_config

    @persisted_vm = mock("persisted_vm")
    Tenderloin::Env.stubs(:persisted_vm).returns(@persisted_vm)

    Net::SSH.stubs(:start)
  end

  context "being an action runner" do
    should "be an action runner" do
      vm = Tenderloin::VM.new
      assert vm.is_a?(Tenderloin::Actions::Runner)
    end
  end

  context "finding a VM" do
    should "return nil if the VM is not found" do
      VirtualBox::VM.expects(:find).returns(nil)
      assert_nil Tenderloin::VM.find("foo")
    end

    should "return a Tenderloin::VM object for that VM otherwise" do
      VirtualBox::VM.expects(:find).with("foo").returns("bar")
      result = Tenderloin::VM.find("foo")
      assert result.is_a?(Tenderloin::VM)
      assert_equal "bar", result.vm
    end
  end

  context "tenderloin VM instance" do
    setup do
      @vm = Tenderloin::VM.new(@mock_vm)
    end

    context "packaging" do
      should "queue up the actions and execute" do
        out_path = mock("out_path")
        action_seq = sequence("actions")
        @vm.expects(:add_action).with(Tenderloin::Actions::VM::Export).once.in_sequence(action_seq)
        @vm.expects(:add_action).with(Tenderloin::Actions::VM::Package, out_path, []).once.in_sequence(action_seq)
        @vm.expects(:execute!).in_sequence(action_seq)
        @vm.package(out_path)
      end
    end

    context "destroying" do
      should "execute the down action" do
        @vm.expects(:execute!).with(Tenderloin::Actions::VM::Down).once
        @vm.destroy
      end
    end

    context "suspending" do
      should "execute the suspend action" do
        @vm.expects(:execute!).with(Tenderloin::Actions::VM::Suspend).once
        @vm.suspend
      end
    end

    context "resuming" do
      should "execute the resume action" do
        @vm.expects(:execute!).with(Tenderloin::Actions::VM::Resume).once
        @vm.resume
      end
    end

    context "starting" do
      setup do
        @mock_vm.stubs(:running?).returns(false)
      end

      should "not do anything if the VM is already running" do
        @mock_vm.stubs(:running?).returns(true)
        @vm.expects(:execute!).never
        @vm.start
      end

      should "execute the start action" do
        @vm.expects(:execute!).once.with(Tenderloin::Actions::VM::Start)
        @vm.start
      end
    end
  end
end
