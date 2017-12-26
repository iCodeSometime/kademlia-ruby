module DHT
  class DataKey
    @attr_reader :id
    ID_LENGTH = 20

    def self.calc_distance(first_id, second_id)
      first_id.zip(second_id).map do |id_1, id_2|
        id_1 ^ id_2
      end.sum
    end

    def initialize(data)
      rng = Random.new(data)
      @id = Array.new(ID_LENGTH) do
        # result will be less than max, thus one byte
        rng.rand(256)
      end
    end
    def distance_to(second_node)
      DataKey.calc_distance(@id, second_node.id)
    end
  end
end
