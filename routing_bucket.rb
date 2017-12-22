module DHT
  class RoutingBucket
    def initialise node_id
      NODE_ID = node_id
      MAX_PEERS = 20
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
