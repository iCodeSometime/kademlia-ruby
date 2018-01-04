require 'minitest/autorun'
require 'kademlia/data_key'

include Kademlia

# String to be used in base hash for some tests.
HASH = '4a4b5775598c7bdc9da54f7ecf2f1f220336b033dbb6547da74d6a0b74eb2819'
Key = DataKey.new(HASH)

class DataKeyTest < Minitest::Test
  def test_initialize
    assert_equal Key.hex, HASH
    assert_equal DataKey.new(Key).hex, HASH
    assert_equal DataKey.new(HASH.to_i(16)).hex, HASH
  end

  def test_create_key_for_content
    text = 'this is a test'
    assert DataKey.for(text).for? text
  end

  def test_conversions
    assert_equal Key, DataKey.new(Key.to_i)
  end

  def test_distance
    distance = 10
    key2 = DataKey.new(HASH.to_i(16) + distance)
    assert Key.distance_to(key2), distance
  end
end
