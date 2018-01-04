# TODO: Rename to Kademlia
module DHT
  ##
  # Stores the Routing Table.
  #
  # All calls to the routing bucket should be called on the routing table.
  # The class determines which bucket should receive the call, and sends it.
  #
  # The only requirement imposed by this architecture is that a data_key must
  # be the first argument to all routing_bucket calls,
  # in order to find the correct bucket. I don't imagine any method that won't
  # need the id of a node, but this should be kept in mind as the app develops.
    class RoutingTable
    def initialize
      @routing_table = []
    end
#TODO read up on method missing, to fill out psudo
    def method_missing method_sym, node_id, *args
      # I like public send to enforce OOP separation
      get_bucket(node_id).public_send(method_sym, node_id, *args)
    end

    # Should select the offset closest bucket. e.g, if the middle element is
    # bucket, should return [4, 2, 0, 1, 3] with increasing offsets
    def next(bucket, offset)
      # Shallow copy
      arr = @routing_table.dup
# TODO: Poor time complexity. Try to come up with something more efficient.
      temp = offset.times do |cur_offset|
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
        ret += next(original_bucket, offset).take(count)
        offset += 1
      end
      ret
    end
  end

  class DhtClient
    ALPHA = 3.freeze
    PORT = 63405.freeze
    def initialize(data)
# TODO: Should this be frozen? Do we want to support changing node id?
# Would it even matter? (no additional privacy, since IP address is known)
      NODE_ID =  DataKey.new(data)

      @routing_buckets = []
      @pending_requests = []
      @threads = []
      @routing_table = RoutingTable.new
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
      RoutingBucket.update_peer(foreign_id, addr, port)
    end



#region: Iterative methods.
# Uses Primative methods found in routing nodes.
# These can block waiting for the response, since they'll have their own thread.
# TODO: Maybe rename these to kademlia_* instead of iterative_*?
    ##
    # Stores a key value pair at
# TODO: Which nodes does it store at?
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
      search(:get_closest_nodes, key)
    end

    ##
    # Performs the node_lookup operation described in the whitepaper.
    #
    # @param [Symbol] A symbol representing the search primitive to call.
    # => Expects the routing node to respond to the symbol, accept a parameter,
    # => and return either an Array of "k" closer nodes, or a value.
    # @param [DataKey] The key being searched for.
    # @return The first non-array value returned from find_function
# TODO: find_node and find_value have almost identical implementations.
# I'll probably need to rewrite this, but there should be a generic function.

# TODO: Finish implementation
    def search(find_function, data_key)
      alpha_contacts = routing_table.get_closest_nodes(ALPHA, data_key)

      threads = alpha_contacts.map do |node|
        node.send(find_function, data_key)
      end
# TODO: probably crashes if all nodes haven't returned
      sleep(5.seconds)
      shortlist = threads.map do |t|
        t[:output]
      end.flatten.sort_by do |node|
        data_key.distance_to(node.node_id)
      end.take(ALPHA)

      closest_node = shortlist.min_by { |n| n.distance_to(data_key) }
    end
#endregion

#region: Event Handlers for RPCs.
    private
    def _ping node_id
      ping(node_id) unless @pending_pings.include?(node_id)
    end

    def _store node_id, key, value
    end

    def _get_closest_nodes
      # Our node shouldn't have been sent, but discard it, if it was.
      # Our node should never get added to the routing table.
    end

    def _find_value node_id, key
    end
#endregion
  end
end
