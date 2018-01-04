require 'minitest/autorun'
require 'kademlia/data_key'

include Kademlia

# String to be used in base hash for some tests.
HASH = '4a4b5775598c7bdc9da54f7ecf2f1f220336b033dbb6547da74d6a0b74eb2819'

class DataKeyTest < Minitest::Test
  def test_initialize
    key = DataKey.new(HASH)
    assert_equal key.hex, HASH
    assert_equal DataKey.new(key).hex, HASH
    assert_equal DataKey.new(HASH.to_i(16)).hex, HASH
  end
  def test_create_key_for_content
    text = 'this is a test'
    assert DataKey.for(text).for? text
  end
  def test_conversions
    key = DataKey.new(HASH)
    assert_equal key, DataKey.new(key.to_i)
  end
end
