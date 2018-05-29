module Kademlia;end
require 'singleton'
# @todo ReOrg. Method missing is not needed.
# Should provide methods to return k closest nodes. Should manage what k is.
# Should handle adding nodes to routing table. THAT IS IT.


##
# Manages the routing table
# TODO: make singleton.
# @todo Can we make replication_factor adjust to the actual churn?
# The paper says it is a system wide setting, but I don't see any reason
# why it needs to be. Each node could adjust their own, based on the actual
# churn observed.
class Kademlia::Routing::Router
  include Singleton

  # Referred to as *k* in the paper.
  @replication_factor = 5
  @routing_table = []

  def register(key)
    @local_key = key
  end

  # @todo I think there are times when we split a routing bucket.
  # That logic should go here.
  def touch(routing_node)
    get_bucket(routing_node.id).touch(routing_node)
  end

  ##
  # Takes an optional offset. Will return either the bucket responsible for the
  # id, or if an offset is given, the bucket offset away. e.g. if the bucket
  # responsible is at index 4, with increasing offsets the function Should
  # return the buckets at 4, 5, 3, 6, 2, 7, 1, 8, 0.
  #
  # @todo currently, this uses mod to wrap around; results may not be correct.
  # Need to think of a better way. It should alternate, but only if the bucket
  # exists. Otherwise should just increase/decrease index directly.
  # A request to get a bucket that does not exist, will cause it to be created.
  # Also, should use separate constant for bucket count, not replication_factor
  def get_bucket(key, offset)
    # Float::to_i simply truncates in ruby.
    bucket_id = Math::log(key.distance_to(@local_id), 2).to_i

    # @todo This part to be redone. Worst case, only half of the buckets are
    # actually closest. e.g. with @replication_factor = 5, and initial bucket=0
    # will return 0, 1, 4, 2, 3. With a proper implementation, 4 will not be
    # returned till last, since it is the farthest away.
    if offset.even?
      bucket_id -= offset / 2
    elsif offset.odd?
      bucket_id += offset / 2 + 1
    end
    bucket_id = bucket_id % @routing_table.length

    return @routing_table[bucket_id]
  end

  def create_bucket
    return RoutingBucket.new(@local_id, @replication_factor)
  end

  def get_closest_nodes(key)
    ret = []
    cur_offset = 0
    tried = 0
    loop do
      bucket = get_bucket(key, cur_offset)
      ret += bucket.nodes
      tried += 1
      break if ret.size >= @replication_factor || tried >= @routing_table.size
      cur_offset += 1
    end
    return ret.first(@replication_factor)
  end
end
