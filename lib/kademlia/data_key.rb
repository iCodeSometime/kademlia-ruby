module Kademlia;end

require 'digest'

##
# A key used to reference nodes or content.
#
# @author Kenneth Cochran
class Kademlia::DataKey
  ##
  # The Digest algorithm we're using.
  # @todo I dislike this name.
  KeyDigest = Digest::SHA256
  ##
  # The size of the Key, in bytes.
  #
  # Times two, since we'll use hexdigest.
  Size = KeyDigest.new.digest_length * 2
#region Constructors
  ##
  # Initializes a new DataKey object with a given key
  #
  # @author Kenneth Cochran
  # @param [Kademlia::DataKey, String, Integer] key
  #  The key to use when creating the ID.
  # @return [void]
  #
  # @todo Data validation.
  def initialize(key)
    @id = case key
    when Kademlia::DataKey then key.hex
    when String then key
    when Integer then key.to_s(16)
    end
  end

  ##
  # Creates a new key for a piece of data.
  #
  # The key ID is set to the hash of the data.
  #
  # @author Kenneth Cochran
  # @param [Object] data The data to create a key for.
  # @return [DataKey] The key belonging to the data.
  def self.for(data)
    self.new(KeyDigest.hexdigest(data))
  end
#endregion
#region Conversions
  ##
  # Return a hexadecimal string representation of the id.
  #
  # @author Kenneth Cochran
  # @return [String] A String representation of the key.
  def hex
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
  # @author Kenneth Cochran
  # @return A String representation of the key.
  def inspect
    '#<Kademlia::DataKey:0x' + hex + '>'
  end

  ##
  # Return an integer representation of the ID.
  #
  # @author Kenneth Cochran
  # @return [Integer] An Integer representation of the key.
  def to_i
    hex.to_i(16)
  end
#endregion
#region Comparisons
  ##
  # Are two data keys equal?
  #
  # @author Kenneth Cochran
  # @param [DataKey] other The object to compare
  # @return [Boolean] Are they equal?
  def ==(other)
    hex == other.hex
  end

  ##
  # (see #==)
  def eql?(other)
    self == other
  end

  ##
  # Determines if a key belongs to a piece of data.
  #
  # @author Kenneth Cochran
  # @param [Object] data The data to compare the key to.
  # @return [Boolean] Does the key belong to the data.
  def for?(data)
    hex == KeyDigest.hexdigest(data)
  end
#endregion
  ##
  # Measures the distance to another key.
  #
  # @author Kenneth Cochran
  # @param [DataKey] other The key to calculate the distance to.
  # @return (see #calc_distance)
  def distance_to(other)
    self.to_i ^ other.to_i
  end
end
