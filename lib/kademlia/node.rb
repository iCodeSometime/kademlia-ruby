# @todo Examples need to be updated.
#   All examples should consider exceptions thrown by druby, and be thoroughy tested.

module Kademlia;end

require 'kademlia/routing'
require 'kademlia/data_key'

##
# Represents the individual nodes in the network.
#   Most of the time, this won't be used directly. All methods only reference
#   things known by the node itself. No network lookups will be done, the node
#   will only check it's current internal state.
class Kademlia::Node
  def initialize(router)
    # @todo Should this be deterministic? e.g. based off mac address?
    @id = DataKey.for(Random.new_seed)
    @values = {}
    @router = router
    @router.register(id)
  end

  ##
  # Returns the id of the node object.
  #
  # @return [DataKey] The id.
  def id
    return @id
  end

  ##
  # The replication factor used by this node.
  #   According to the paper, this should be a network wide constant, so this
  #   method wouldn't be needed, but I'dlike to experiment with dynamically
  #   adjusting it to the actual observed uptime of nodes.
  #
  # @return [Integer] the replication factor used by this node.
  def replication_factor
    return @router.replication_factor
  end

  ##
  # Check if node is up.
  #
  # @param calling_node [Node] The node object for the calling node.
  # @example Check if this node is still up.
  #   if remote_node.ping(my_node)
  #     # it's up.
  #   else
  #     # it's not up
  #   end
  #
  # @todo provide better example.
  #   Druby throws an exception if the target of invocation is not reachable.
  def ping(calling_node)
    @router.touch(calling_node)
    return true
  end

  ##
  # Returns the replication_factor closest nodes to a given key.
  #
  # @param calling_node [Node] The node object for the calling node.
  # @param key [DataKey] The key to find the closest nodes to.
  # @return [Array<Node>] An array containing the closest known nodes to key.
  #   This will normally have a length of replication_factor. The only exception
  #   is if this node does not have that many nodes in it's routing table, in
  #   which case, it will contain all known nodes.
  # @example Find the closest node to a key.
  #   remote_node.find_node(my_node, key).each do |node|
  #     # Do something with the returned nodes.
  #   end
  def find_node(calling_node, key)
    @router.touch(calling_node)
    return @router.get_closest_nodes(key)
  end

  ##
  # Returns the value if stored here, or the replication_factor closest nodes.
  #   This will return the value represented by a key if it is stored at this
  #   node, otherwise it will behave identically to find_node.
  # @see find_node
  # @param calling_node [Node] The node object for the calling node.
  # @param key [DataKey] The key to find the value for.
  # @return [DataItem] if this node stores the value to search for.
  # @return [Array<Node>] if the value is not stored at this node.
  #   Identical to find_node in this case.
  # @example Find a value.
  #   key = DataKey.for('key')
  #   res = remote_node.find_value(my_node, key)
  #   if res.method_defined? :each
  #     # Do something with the array of nodes.
  #   else
  #     # Do something with the value we were finding.
  #   end
  def find_value(calling_node, key)
    @router.touch(calling_node)
    value = @values[key.to_bin]
    return value unless value.nil?
    return find_node(key)
  end

  ##
  # Stores the given value at this node.
  #   The node is required to store the value. It is generally not recommended
  #   to call this method directly, as lookup methods will not work properly
  #   unless the value is stored at the proper nodes.
  # @param calling_node [Node] The node object for the calling node.
  # @param key [DataKey] The key to use for the item being stored.
  # @param value [DataItem] The value to store.
  # @return [Boolean] Were we able to store the item?
  # @example Store a string.
  #   val = 'stringtostore'
  #   key = DataKey.for(val)
  #   to_store = DataItem.new(val)
  #   if remote_node.store(my_node, key, to_store)
  #     # It was stored successfully.
  #   else
  #     # Something went wrong.
  #   end
  def store(calling_node, key, value)
    @router.touch(calling_node)
    return false unless key.class == DataKey
    @values[key.to_bin] = value
    return true
  end

  ##
  # A node is equal to another node, if their IDs are the same.
  #   Technically, they could be different, but at this point it would be much
  #   more expensive to do a more thorough check, for minimal gain.
  #   Asymmetric key cryptography based identity is on the roadmap.
  # @param other [Node] The other node to compare to.
  # @return [Boolean] is this the same node?
  def ==(other)
    return false if other.class != Node
    return id == other.id
  end
end
