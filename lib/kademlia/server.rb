module Kademlia; end

require 'drb/drb'
require 'kademlia/routing/router'
require 'kademlia/node'
require 'kademlia/data_item'
require 'singleton'
require 'thwait'
require 'set'

##
# The actual Kademlia server, which will handle all requests.
#
# Any compression or encryption will be handled here also.
class Kademlia::Server
  include Singleton

  @URI = nil
  @concurrent_lookups = 3
  @router = Kademlia::Routing::Router.instance
  @my_node = Kademlia::Node.new(@router)

  def uri
    return @URI
  end

  def uri=(uri)
    # Only allow assignment once.
    @URI ||= uri
  end

  # @todo Is this actually needed?
  # Update, pretty sure it is at least for bootstrapping.
  def get_node
    return @my_node
  end

  def node_lookup(key)
    _node_lookup(key) do |contact|
      Thread.current[:contacts] = contact.find_node(@my_node, key)
    end
  end

  def value_lookup(key)
    _node_lookup(key) do |contact|
      res = contact.find_value(@my_node, key)
      if res.class = DataItem
        Thread.current[:value] = res
      else
        Thread.current[:contacts] = res
      end
    end
  end

  def store(key, value)
    node_lookup(key).each do |contact|
      contact.store(@my_node, key, value)
    end
  end
  private

  ##
  # Returns the k closest nodes to key.
  # block given must expose contacts returned, and a value, if any.
  def _node_lookup(key, &block)
    # Build initial contact list.
    contacts = @my_node.find_node(@my_node.id)
    contact_list = ContactsList.new(contacts, key)

    # Build initial threadpool.
    threads = contact_list.get_threads(@concurrent_lookups, &block)
    tw = ThreadWait.new(threads)

    # Add a new thread each time one completes, until all nodes have been tried.
    loop do
      # Process the result of the next thread.
      thread = tw.next_wait
      return [thread[:value], contact_list.contacts] if thread[:value]
      new_contacts = thread[:contacts] || []
      @router.touch(new_contacts)
      contact_list.add_contacts(new_contacts)

      # Add next thread if exists, and exit if done.
      tw.join_nowait(contact_list.get_threads(1, &block)) unless contact_list.all_tried?
      break if tw.empty? and not tw.finished?
    end
    return contact_list.contacts
  end

  # This class is NOT thread safe, and should only be accessed by one thread.
  # This is an implementation detail, added to keep _node_lookup dryyyy
  # Private means nothing in this instance, just here for reading clarity.
  private
  # @todo make sure this whole thing makes sense.
  class ContactsList
    def initialize(contacts, key)
      # The key is used to find the distance to.
      @key = key
      @contacts = contacts
      @max_size = @contacts.size
      @tried = Set.new
    end

    def contacts
      return _sort_contacts(@contacts)
    end

    def get_threads(num, &block)
      shortlist = _not_tried(self.contacts).first(num)

      @tried |= shortlist

      return shortlist.map do |contact|
        Thread.new(contact, &block)
      end
    end

    def add_contacts(contacts)
      @contacts = _sort_contacts((@contacts + contacts).uniq).first(@max_size)
    end

    def all_tried?
      return _not_tried(@contacts).length == 0
    end

    private
    def _sort_contacts(contacts)
      return contacts.sort_by do |contact|
        contact.id.distance_to_key(@key)
      end
    end

    def _not_tried(contacts)
      return contacts.reject do |contact|
        tried.include? contact
      end
    end
  end
end

# Port zero allows the OS to choose the port.
URI = 'druby://localhost:0'
FRONT_OBJECT = Kademlia::Server.instance

# @todo explicitly undef unsafe methods in Kademlia::Server and Node
# $SAFE is not implemented in rubinius. This would just be defining a new global
$SAFE = 1

# Need to wait till here, so the OS has assigned us a port number.
Kademlia::Server.instance.uri = DRb.start_service(URI, FRONT_OBJECT).uri
