module Kademlia;end

require 'singleton'
require 'kademlia/server'
require 'kademlia/data_key'
require 'drb/drb'

##
# The Client class contains all of the methods designed to be called directly
# by the user.
#
# @author Kenneth Cochran
class Kademlia::Client
  include Singleton

  # TODO: Allow choosing the first client to connect to.
  SERVER_URI = Kademlia::Server.instance.uri
  DRb.start_service
  Server = DRbObject.new_with_uri(SERVER_URI)

  def store(data)
    key = Kademlia::DataKey.for(data)
    thread = Thread.new(key, data) do |key, data|
      Server.store(key, data)
    end
    return key, thread
  end

  def [](key, &block)
    if block_given?
      _async_retrieve(key, block)
    else
      return _sync_retrieve(key)
    end
  end

  # @todo not sure this is the best way to do this.
  # Internally, the server is going to be parellelizing requests anyways.
  # We should probably just have these implemented in there.
  private
  def _sync_retrieve(key)
    return Server.retrieve(key)
  end

  def _async_retrieve(key, &block)
    return Thread.new(key, &block) do |key, &block|
      block.call(Server.retrieve(key))
    end
  end
end

Kad = Kademlia::Client.instance
