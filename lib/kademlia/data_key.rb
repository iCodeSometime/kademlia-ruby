module Kademlia;end

require 'digest'

# @todo I'll need to profile to determine the tradeoffs between storing the key
# in binary and taking longer to convert it to an integer the first time (it has
# to go through hex first) Or storing it in hex then converting to binary to
# transmit. Or maybe even just leave it in hex. I think memoizing #to_i is good
# enough for now.

##
# A key used to reference nodes or content.
#
# @author Kenneth Cochran
class Kademlia::DataKey
  ##
  # The Digest algorithm we're using.
  DigestGenerator = Digest::SHA256
  ##
  # The size of the Key, in bytes.
  #
  # Times two, since we'll use hexdigest.
  Size = DigestGenerator.new.digest_length

  ##
  # Initializes a new DataKey object with a given key
  #
  # @param [Kademlia::DataKey, String, Integer] key
  #  The key to use when creating the ID.
  # @return [void]
  #
  # @todo Can we abort initilization if it's already a datakey?
  def initialize(key)
    @id = case key
          when Kademlia::DataKey then key.to_bin
          when String
            case key.size
            # If it's in the right format
            when Size then key
            # If it's hex
            when Size * 2 then [key].pack('H*')
            end
          when Integer
            @int_val = key
            ["%0#{Size}d" % key.to_s(16)].pack('H*')
          end

    raise ArgumentError, "#{key} is not a valid key." if @id.nil?
  end

  ##
  # Creates a new key for a piece of data.
  #
  # The key ID is set to the hash of the data.
  #
  # @param [Object] data The data to create a key for.
  # @return [DataKey] The key belonging to the data.
  def self.for(data)
    self.new(DigestGenerator.digest(data))
  end

  ##
  # Return a hexadecimal string representation of the id.
  #
  # @return [String] A String representation of the key.
  def hex
    @id.unpack('H*').first
  end

  ##
  # Return a binary representation of the id.
  #
  # @author Kenneth Cochran
  # @return [String] The actual key in binary.
  def to_bin
    @id
  end

  ##
  # (see #hex)
  def to_s
    hex
  end

  ##
  # The preferred representation for debugging.
  #
  # @return A String representation of the key.
  def inspect
    '#<Kademlia::DataKey:0x' + hex + '>'
  end

  ##
  # Return an integer representation of the ID.
  #
  # @return [Integer] An Integer representation of the key.
  def to_i
    # This will be common. Memoize for efficiency.
    @int_val ||= hex.to_i(16)
  end

  ##
  # Are two data keys equal?
  #
  # @param [DataKey] other The object to compare
  # @return [Boolean] Are they equal?
  def ==(other)
    @id == other.to_bin
  end

  ##
  # (see #==)
  def eql?(other)
    self == other
  end

  ##
  # Determines if a key belongs to a piece of data.
  #
  # @param [Object] data The data to compare the key to.
  # @return [Boolean] Does the key belong to the data.
  def for?(data)
    @id == DigestGenerator.digest(data)
  end

  ##
  # Measures the distance to another key.
  #
  # @param [DataKey] other The key to calculate the distance to.
  # @return (see #calc_distance)
  def distance_to(other)
    self.to_i ^ other.to_i
  end
end
