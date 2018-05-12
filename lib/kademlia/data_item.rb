module Kademlia;end
#TODO: validate constants usage with standard
class Kademlia::DataItem
  def initialize
    # How long it takes a piece of data to expire in seconds
    # incremented 10 sec from the whitepaper.
    # ref http://xlattice.sourceforge.net/components/protocol/kademlia/specs.html
    ## "As noted earlier, the requirement that tExpire and tRepublish have the
    ## same value introduces a race condition: data will frequently be
    ## republished immediately after expiration. It would be sensible to make
    ## the expiration interval tExpire somewhat greater than the republication
    ## interval tRepublish. The protocol should certainly also allow the
    ## recipient of a STORE RPC to reply that it already has the data, to save
    ## on expensive network bandwidth."
    EXPIRE_TIME_SEC = 86_410
    # How long before we refresh the data in seconds
    REFRESH_TIME_SEC = 3_600
    # How long before we replicate the data in seconds
    REPLICATE_TIME_SEC = 3_600
    # How long before we republish the data in seconds
    REPUBLISH_TIME_SEC = 86_400
  end
end
