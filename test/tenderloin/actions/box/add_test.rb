require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class AddBoxActionTest < Test::Unit::TestCase
  setup do
    @runner, @vm, @action = mock_action(Tenderloin::Actions::Box::Add)
    mock_config
  end

  context "prepare" do
    setup do
      @default_order = [Tenderloin::Actions::Box::Download, Tenderloin::Actions::Box::Unpackage]
      @runner.stubs(:directory).returns("foo")
      File.stubs(:exists?).returns(false)
    end

    def setup_action_expectations
      default_seq = sequence("default_seq")
      @default_order.each do |action|
        @runner.expects(:add_action).with(action).once.in_sequence(default_seq)
      end
    end

    should "setup the proper sequence of actions" do
      setup_action_expectations
      @action.prepare
    end

    should "result in an action exception if the box already exists" do
      File.expects(:exists?).once.returns(true)
      @runner.expects(:name).twice.returns('foo')
      @runner.expects(:add_action).never
      assert_raise Tenderloin::Actions::ActionException do
        @action.prepare
      end
    end
  end
end
