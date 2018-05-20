module Kademlia;end
#TODO: validate constants usage with standard
class Kademlia::DataItem
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
  def initialize(data)
    @data = data

    reset_expire
    reset_refresh
    reset_replicate
    reset_republish
  end

  def expired?
    return @expire_time < Time.now
  end
  def refresh?
    return @refresh_time < Time.now
  end
  def replicate?
    return @replicate_time < Time.now
  end
  def republish?
    return @republish_time < Time.now
  end
  
  def reset_expired
    @expire_time = Time.now + EXPIRE_TIME_SEC
  end
  def reset_refresh
    @refresh_time = Time.now + REFRESH_TIME_SEC
  end
  def reset_replicate
    @replicate_time = Time.now + REPLICATE_TIME_SEC
  end
  def reset_republish
    @republish_time = Time.now + REPUBLISH_TIME_SEC
  end
end
