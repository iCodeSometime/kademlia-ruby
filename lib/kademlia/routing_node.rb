# @todo ReArchitect - the routing node will contain the non-iterative methods
# and anything that should not be called directly from the client. DRuby
# references to these will be retrieved by the server, and stored in the routing
# table.
module Kademlia;end

require 'kademlia/routing'
require 'kademlia/data_key'

class Kademlia::RoutingNode
  def initialize(router)
    @values = {}
    @router = router
  end

  ##
  # Lazy generate or return the key.
  def id
    return @id ||= DataKey.for(Random.new_seed)
  end

  ##
  # Check if node is up.
  def ping(routing_node)
    @router.try_store(routing_node)
    return true
  end

  ##
  # Returns k closest nodes.
  def find_node(routing_node, key)
    @router.try_store(routing_node)
    return @router.get_closest_nodes(key)
  end

  ##
  # Returns the value if stored here, or k closest nodes.
  def find_value(routing_node, key)
    @router.try_store(routing_node)
    value = @values[key]
    return value unless value.nil?
    return find_node(key)
  end

  ##
  # Stores the value here.
  def store(routing_node, key, value)
    @router.try_store(routing_node)
    # I thought of just requiring that keys implement distance_to, but using
    # custom keys is going to cause problems retrieving data. It's either that, or
    # use only the hash as the key..
    # @todo Will it be better to use key.to_bin? I don't think there's any advantage
    # to storing the whole object here.
    return false unless key.class == DataKey
    @values[key] = value
    return true
  end
end
