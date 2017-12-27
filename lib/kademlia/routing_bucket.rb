module DHT
  class RoutingBucket
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
      @table.insert(0, @table.delete(@table.find_index(node))
    end
    # Expects a verified node.
    # We add new nodes to the front; the opposite of the kademlia standard.
    def _add_peer!(node)
      @table.unshift(node)
    end
  end
end
