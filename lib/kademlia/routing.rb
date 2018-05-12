module Kademlia;end

##
# Stores the Routing Table.
#
# All calls to the routing bucket should be called on the routing table.
# The class determines which bucket should receive the call, and sends it.
#
# The only requirement imposed by this architecture is that a data_key must
# be the first argument to all routing_bucket calls,
# in order to find the correct bucket. I don't imagine any method that won't
# need the id of a node anyways, but this should be kept in mind.
# TODO: make singleton.
class Kademlia::Routing
  def initialize
    @routing_table = []
  end
#TODO read up on method missing to fill out psudo. Should transparently proxy
# Calls to the correct routing bucket.
  def method_missing method_sym, node_id, *args
    # I like public send to enforce OOP separation.
    # Ruby has a weird paradigm where you can actually call private methods.
    get_bucket(node_id).public_send(method_sym, node_id, *args)
  end

  # Should select the offset closest bucket. e.g, if the middle element is
  # bucket, should return [4, 2, 0, 1, 3] with increasing offsets
  def bucket_at_offset(bucket, offset)
    # Shallow copy
    arr = @routing_table.dup
# TODO: I'm sure there's a much much better way to do this.
    offset.times do |cur_offset|
      arr.pop(bucket + (cur_offset.even? ? cur_offset : 0))
    end
  end

  def get_bucket foreign_id
    dist = NODE_ID.distance_to(foreign_id)
    bucket_id = k.times do |n|
      break n - 1 if 2 ** n > dist
    end
    @routing_table[bucket_id]
  end
  def get_closest_nodes(count, data_key)
    ret = []
    original_bucket = get_bucket(data_key)
    offset = 0
    until ret.length >= count
      # Ruby concatenates here; no need to flatten
      ret += bucket_at_offset(original_bucket, offset).take(count)
      offset += 1
    end
    ret
  end

  # The routing bucket should only be accessible from the routing table singleton.
  class Kademlia::RoutingBucket
    # Also known as "k". Should be set to a value that makes it very unlikely
    # that a node will lose all of it's valid contacts. Should be adjusted with churn.
    MAX_PEERS = 20
    def initialise node_id
      NODE_ID = node_id
      @table = []
    end
    # This should not be used as part of the update process for external callers.
    # Always call update_peer every time a peer is contacted.
    def have_node?(node)
      @table.include?(node)
    end
    # Main entrypoint for all RoutingBucket peer logic.
    # Should be called every time a peer is contacted.
    def update_routing(node_id, addr, port)
      # Our node ID should never be in the routing bucket.
      return nil if node_id == NODE_ID
      node = RoutingNode.new(node, addr, port)
      if have_node?(node)
        _update_peer!(node)
      else
        _add_peer!(node)
      end
    end

    def take(count)
      @table.take(count)
    end

    private
    # Expects a verified node.
    # We move the most recent to the front; the opposite of the kademlia standard.
    def _update_peer! node
      @table.insert(0, @table.delete(@table.find_index(node)))
    end
    # Expects a verified node.
    # We add new nodes to the front; the opposite of the kademlia standard.
    def _add_peer!(node)
      @table.unshift(node)
    end
  end
end
