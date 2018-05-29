# @todo ReArchitect - the routing node will contain the non-iterative methods
# and anything that should not be called directly from the client. DRuby
# references to these will be retrieved by the server, and stored in the routing
# table.
module Kademlia;end

require 'kademlia/routing'
require 'kademlia/data_key'

## @todo should I factor out a generic send message command so I don't have to
# remember to call @router.touch for each method??

class Kademlia::Node
  def initialize(router)
    # @todo Should this be deterministic? e.g. based off mac address?
    @id = DataKey.for(Random.new_seed)
    @values = {}
    @router = router
    @router.register(id)
  end

  def id
    return @id
  end

  ##
  # Check if node is up.
  def ping(calling_node)
    @router.touch(calling_node)
    return true
  end

  ##
  # Returns k closest nodes.
  def find_node(calling_node, key)
    @router.touch(calling_node)
    return @router.get_closest_nodes(key)
  end

  ##
  # Returns the value if stored here, or k closest nodes.
  def find_value(calling_node, key)
    @router.touch(calling_node)
    value = @values[key.to_bin]
    return value unless value.nil?
    return find_node(key)
  end

  ##
  # Stores the value here.
  def store(calling_node, key, value)
    @router.touch(calling_node)
    return false unless key.class == DataKey
    @values[key.to_bin] = value
    return true
  end

  def ==(other)
    return id == other.id
  end
end
