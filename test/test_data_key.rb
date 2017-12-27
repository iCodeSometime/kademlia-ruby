require 'minitest/autorun'
require 'kademlia/data_key'

include Kademlia

class DataKeyTest < Minitest::Test
  def test_new_object
    assert_instance_of DataKey, DataKey.new(1)
  end
end
