require 'digest'
module DHT
  ##
  # Stores the Routing Table.
  # TODO: metaprogramming..? I had a good idea about using method missing here,
  # to pass the methods transparently to the node, but not sure I like it now.
  class RoutingTable
    def initialize
      @routing_table = []
    end
    #TODO read up on method missing, to fill out psudo
    def method_missing node_id, *args
      get_bucket(node_id).__method__name__(node_id, *args)
    end

    def get_bucket
      dist = NODE_ID.distance_to(foreign_id)
      bucket_id = k.times do |n|
        break n - 1 if 2 ** n > dist
      end
      @routing_table[bucket_id]
    end
  end
  class DhtClient
    def initialize(data)
      ID_LENGTH = 16
      NODE_ID =  DataKey.new(data)
      CONCURRENT_REQUESTS = 3
      PORT = 63405

      @routing_buckets = []
      @pending_requests = []
      @threads = []
      client_loop
    end

# TODO: Should have CURRENT_REQUEST threads
    def client_loop
# TODO: Should not be dealing directly with sockets in high level code.
      socket = UDPSocket.new
      socket.bind('0.0.0.0', PORT)
      while true
        data, header = socket.recvfrom(10)
        node_id, command, *args = data.split
        proto, port, sender, receiver = header ## TODO: check sender/receiver
        update_routing(node_id, sender, port) #IP/sock
        begin
          self.send(('_' + command).to_sym, node_id, *args)
        rescue NoMethodError
          # p = puts
          p node_id + ' tried to call ' + command + ' ' + args.inspect if $DEBUG
        end
      end
    end

    def update_routing(foreign_id, addr, sock)
      routing_bucket(foreign_id).update_peer(foreign_id, addr, port)
    end

    # 2^bucket <= distance_to(foreign_id) < 2^(bucket + 1)
# TODO: I'm not sure I like this being in the DhtClient class.
# e.g. RoutingBucket[foreign_key]
    def routing_bucket(foreign_id)
      dist = NODE_ID.distance_to(foreign_id)
      bucket_id = k.times do |n|
        break n - 1 if 2 ** n > dist
      end
      @routing_buckets[bucket_id]
    end

#region: Iterative methods.
# Uses Primative methods found in routing nodes.
# These can block waiting for the response, since they'll have their own thread.
# TODO: Maybe rename these to kademlia_* instead of iterative_*?
    ##
    # Stores a key value pair at TODO: Which nodes does it store at?
    #
    # @note This method is blocking and should be called in it's own thread
# TODO: Should I create the threads in the functions?
    def iterative_store(key, value)
# TODO: fill in psudo
      find_node(key).each do |node|
        node.store(key, value)
      end
    end
    ##
    # Finds a given node.
    #
    # @note (see #iterative_store)
    def iterative_find_node node_id
      search(:find_node, node_id)
    end
    ##
    # Finds the value associated with a given key.
    #
    # @note (see #iterative_store)
    def iterative_find_value key
      search(:find_value, key)
    end

    ##
    # Performs the node_lookup operation described in the whitepaper.
    #
    # @param [Symbol] A symbol representing the search primitive to call.
    # => Expects the routing node to respond to the symbol, accept a parameter,
    # => and return either an Array of "k" closer nodes, or a value.
    # @param [DataKey] The key being searched for.
    # @return The first non-array value returned from find_function
# TODO: Not positive I'll be able to use this.
#`find_node` always returns "k" closest.
# renamed it to get_closest_nodes because of this confusion.
# I'll need to learn more about how find_node should work in order to determine
# If this is a valid architecture.
    def search(find_function, node)

    end
#endregion

#region: Event Handlers for RPCs.
    private
    def _ping node_id
      ping(node_id) unless @pending_pings.include?(node_id)
    end

    def _store node_id, key, value
    end

    def _find_node node_id
      # Our node shouldn't have been sent, but discard it, if it was.
      # Our node should never get added to the routing table.
    end

    def _find_value node_id, key
    end
#endregion
  end
end
