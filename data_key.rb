module DHT
  class DataKey
    ID_LENGTH = id_length
    def self.calc_distance(first_id, second_id)
      first_id.zip(second_id).map do |id_1, id_2|
        id_1 ^ id_2
      end
    end
    # Currently only supports MD5.length as max.
    def initialize(data)
      @id = Digest::MD5.hexdigest(data).split('')[0..ID_LENGTH]
    end
    def distance_to(foreign_id)
      DataKey.calc_distance(@id, foreign_id)
    end
  end
end
