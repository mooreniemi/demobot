require "./command"
require "test/unit"


class DefaultCommandListTest < Test::Unit::TestCase

  def setup
    assert_nothing_raised do
      @c = CommandList.new() { |matches, line| @last_called = :ambiguity
        @last_data = [matches, line] }
      
      @c.register("vk", true) { @last_called = :vk }
      @c.register("register") { @last_called = :register }
      @c.register("voteban") { @last_called = :voteban }
      @c.register("votekick") { @last_called = :votekick }
      @c.register("votetopic") { @last_called = :votetopic }
      @c.register("zongledingle") { @last_called = :zongledingle }
      @c.register("z") { @last_called = :z }
      
      @c.register_error_handler { @last_called = :error }
      
      @last_called = nil
      @last_data = nil
    end
  end
  
  def test_look_up
    assert_nothing_raised do
      assert_equal ["voteban", "votekick", "votetopic"], @c.look_up("v")
      assert_equal ["zongledingle"], @c.look_up("zo")
      assert_equal [], @c.look_up("something that doesn't exist")
    end
  end
  
  def test_execute
    assert_nothing_raised do
      @c.execute("voteb", nil)
      assert_equal :voteban, @last_called
    end
  end
  
  def test_ambiguity
    assert_nothing_raised do
      @c.execute("vote", nil)
      assert_equal :ambiguity, @last_called
      assert_equal [["voteban", "votekick", "votetopic"], "vote"], @last_data
    end
  end
  
  def test_error
    assert_nothing_raised do
      @c.execute("something that doesn't exist", nil)
      assert_equal :error, @last_called
    end
  end

end
