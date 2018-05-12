module Kademlia; end

require 'drb/drb'

##
# The actual Kademlia server, which will handle all requests.
#
# Any compression or encryption will be handled here also.
class Kademlia::Server

end

# Port zero allows the OS to choose the port.
URI = 'druby://localhost:0'
FRONT_OBJECT = Server.new

# @todo This is not implemented in rubinius. Need to also explicitly undef
# unsafe methods in Kademlia::Server
$SAFE = 1

DRb.start_service(URI, FRONT_OBJECT)
