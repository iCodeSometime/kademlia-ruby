module Kademlia; end

require 'drb/drb'
require 'singleton'

##
# The actual Kademlia server, which will handle all requests.
#
# Any compression or encryption will be handled here also.
class Kademlia::Server
  include Singleton

  @URI = nil
  bootstrap

  def uri
    @URI
  end
  def uri=(uri)
    # Only allow assignment once.
    @URI ||= uri
  end

  def bootstrap

  end
end

# Port zero allows the OS to choose the port.
URI = 'druby://localhost:0'
FRONT_OBJECT = Kademlia::Server.instance

# @todo This is not implemented in rubinius.
# Need to also explicitly undef unsafe methods in Kademlia::Server
$SAFE = 1

Kademlia::Server.instance.uri = DRb.start_service(URI, FRONT_OBJECT).uri
