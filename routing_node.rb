module DHT
  #TODO: Need to define comparison function, to use `find_index`.
  #TODO: Needs equality operator, to use `include?`
  class RoutingNode
    attr_accessor: :node_id, :ip_address, :udp_port
    def initialize(node_id, ip_address, udp_port)
      @node_id = node_id
      @ip_address = ip_address
      @udp_port = udp_port
    end

#region Primative methods.
    ##
    # Pings the node to ensure it's still online.
    # @param node_id [DHT::DataKey] the id of the node to ping.
    def ping(node_id)
      # Send the ping to the node.
    end

    def store(node_id, key, value)

    end
    ##
    # Returns the closest nodes, up to "k".
    # @param (see #ping)
# TODO: Name as written in spec seems misleading.

    def get_closest_nodes(node_id)
      # Should never send requestor's node.
    end

    def find_value(key)
    end
#endregion
  end
end
