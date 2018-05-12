module Kademlia;end

require 'singleton'
require 'kademlia/server'
require 'kademlia/data_key'

##
# The Client class contains all of the methods designed to be called directly
# by the user.
#
# @author Kenneth Cochran
class Kademlia::Client
  include Singleton

  SERVER_URI = Kademlia::Server.instance.uri
  DRb.start_service
  Server = DRbObject.new_with_uri(SERVER_URI)

  def store(data)
    key = Kademlia::DataKey.for(data)
    thread = Thread.new(key, data) do |key, data|
      Server.store(key, data)
    end
    return [key, thread]
  end

  def [](key, &block)
    if block_given?
      async_retrieve(key, block)
    else
      return sync_retrieve(key)
    end
  end

  def sync_retrieve(key)
    return Server.retrieve(key)
  end

  def async_retrieve(key, &block)
    return Thread.new(key, &block) do |key, &block|
      block.call(Server.retrieve(key))
    end
  end
end

Kad = Kademlia::Client.instance
