module DHT
  ##
  # A key used to reference nodes or content.
  #
  # @author Kenneth Cochran
  # @attr_reader [Number] ID_LENGTH The constant length of the ID. Must match all nodes on network.
  # @attr_reader [Array<Integer>] id The ID_LENGTH Byte Array representing the id.
  class DataKey
    @attr_reader :id
    ID_LENGTH = 20

    ##
    # Calculates the distance between two id's.
    #
    # @todo Should be private?
    # @author Kenneth Cochran
    #
    # @param [Array<Number>] first_id A byte array of ID_LENGTH.
    # @param [Array<Number>] second_id A byte array of ID_LENGTH.
    #
    # @return [Number] The distance between the IDs
    def self.calc_distance(first_id, second_id)
      first_id.zip(second_id).map do |id_1, id_2|
        id_1 ^ id_2
      end.sum
    end

    ##
    # Initializes a new DataKey object from a given data to be used as a seed.
    #
    # @param [Number] data The seed to use when generating the id.
    # @return [void]
    def initialize(data)
      rng = Random.new(data)
      @id = Array.new(ID_LENGTH) do
        # result will be less than max, thus one byte
        rng.rand(256)
      end
    end

    ##
    # Measures the distance to another key.
    #
    # @param [DataKey] second_key The key to calculate the distance to.
    # @return (see #calc_distance)
    def distance_to(second_key)
      DataKey.calc_distance(@id, second_node.id)
    end
  end
end
