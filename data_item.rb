module DHT
#TODO: validate constants usage with standard
  class DataItem
    def initialize
      # How long it takes a piece of data to expire in seconds
      # incremented 10 sec from the whitepaper.
      # ref http://xlattice.sourceforge.net/components/protocol/kademlia/specs.html
      EXPIRE_TIME_SEC = 86_410
      # How long before we refresh the data in seconds
      REFRESH_TIME_SEC = 3_600
      # How long before we replicate the data in seconds
      REPLICATE_TIME_SEC = 3_600
      # How long before we republish the data in seconds
      REPUBLISH_TIME_SEC = 86_400
    end
  end
end
