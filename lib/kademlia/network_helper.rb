# TODO Pretty sure I want to replace this whole thing with druby.

module Helper::Network; end
##
# A cache with garbage collection.
#
# Automatically removes items longer than timeout from the cache.
# @author Kenneth Cochran
#
# @todo Add thread safety.
class Helper::Network::GC_Cache
  def initialize(timeout)
    @cache = {}
    remove_stale(timeout)
  end

  ##
  # The garbage collection for the class. Started by init.
  #
  # Sleeps for timeout, and then deletes any packets older than timeout.
  #
  # @author Kenneth Cochran
  # @param [to_i] timeout The timout to wait before collecting stale items
  def remove_stale(timeout)
    Thread.new(timeout) do |timeout|
      loop do
        Thread.sleep(timeout)
        @cache.each do |key, value|
          @cache.delete(key) if value.time_since_update > timeout
        end # @cache.each
      end # loop do
    end # Thread.new
  end # def remove_stale

  def [](key)
    @cache[key]
  end

  def []=(key, value)
    @cache[key] = value
  end

  ##
  # Deletes a and returns an item from the cache. Returns nil if not present.
  #
  # @author Kenneth Cochran
  # @param [#to_sym] key The key to get
  def delete(key)
    @cache.delete(key.to_sym)
  end
end # class Cache

##
# Base class. Inheriting this class makes you compatible with GC_Cache.
class TimeTracker
  def initialize
    @last_updated = Time.now
  end

  ##
  # Returns the length of time since the last update.
  #
  # This is a requirement for our garbage collected cache.
  #
  # @author Kenneth Cochran
  def time_since_update
    Time.now - @last_updated
  end
end

##
# A partial message for use in rebuilding the original.
#
# @author Kenneth Cochran
class MessageBuilder < TimeTracker
  def initialize(raw_message)
    super
    # @todo This could change
    @size,
    @id,
    message = message_splitter(raw_message)
    @partial_messages = [message]
  end

  ##
  # Adds to the list of partial messages.
  # Returns true if all messages are present, false otherwise
  #
  # @author Kenneth Cochran
  # @param [Object] message The message to add.
  # @return [MessageBuilder] self
  def add(message)
    @partial_messages += message.partial_messages
    @last_updated = Time.now
    return self
  end

  def self.message_splitter(raw_message)
    # @todo Decide the message format
    # partial_messages needs an order
  end

  def build_message
    raise if @size != @partial_messages.length

    @partial_messages.sort_by do |message|
      message.order
    end.map do |message|
      message.content
    end.join
  end
end
