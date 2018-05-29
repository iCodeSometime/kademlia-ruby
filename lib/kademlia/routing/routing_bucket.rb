module Kademlia; end
# @todo ReOrg. The routing bucket should determine whether or not a given node
# actually gets entered. e.g. if there is room in the bucket, or a node is stale
# Most of this is unneeded.
#
# The documentation states that the array should be ordered by most recent seen.
# Instead of that, I'm just keeping track of last seen.

  class Kademlia::Router::RoutingBucket
    private_constant :Peer
    def initialise(local_id, max_peers)
      @local_id = local_id
      @max_peers = max_peers
      @table = []
    end

    # @todo this should probably be renamed.
    def touch(routing_node)
      return true if _add_or_update!(routing_node)
      # Find a stale node, if it's not present and there's no opening.
      # @todo Find a way to return nil here, instead of the whole array.
      stale_index = @table.each_index do |peer, index|
        break index unless peer.routing_node.ping
      end
      # Return false if there were no stale nodes
      return false if stale_index.class == @table.class
      # Remove the stale node, and add the new one.
      @table.delete_at(stale_index)
      return _add(routing_node)
    end

    private
    def _add_or_update(routing_node)
      peer = _find_peer(routing_node)
      if peer
        peer.update
        return true
      else
        return _add!(routing_node)
      end
    end

    def _add(routing_node)
      if @table.length < @max_peers
        @table << Peer.new(routing_node)
        return true
      end
      return false
    end

    def _find_peer(routing_node)
      index = @routing_table.index(routing_node)
      return @routing_table[index] unless index.nil?
      return false
    end

    # Routing::RoutingBucket::Peer
    # This is needed to take advantage of Ruby's built in enumerator methods
    class Peer
      attr_reader :routing_node
      def initialize(routing_node)
        @routing_node = routing_node
        @last_seen = Time.now
      end
      def update
        @last_seen = Time.now
      end

      def ==(other)
        return @routing_node == other if other.class == RoutingNode
        return @routing_node == other.routing_node
      end
    end
  end
