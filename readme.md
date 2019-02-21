This project is a work in progress, and is currently non-functional.
Anything in this readme, is a work in progress, and may change.

# Installation
 `gem install Kademlia`

## Usage
```Ruby
# @todo Should we be able to choose a key? Or should it always be the hash

require 'kademlia'
# Storing is asynchronous
key, thread = Kad.store(File.read('filename'))
thread.join
# Retrieving here is synchronous. Make sure your UI is in a separate thread, if applicable
file_content = Kad[key]
# Alternatively, provide a block to retrieve asynchronously
thread = Kad[key] do |content|
  # Do something with the content
end
thread.join
```

This project makes no claim to be a strict implementation of the original paper,
and in it's initial implementation will not be compatible with implementations that
are. Rather it is  a Ruby flavored interpretation of the spec, passing around druby
objects as the network nodes, and calling commands directly on these, rather than
sending UDP packets.

While it's meant to conform fairly closely with the original paper, in any
tradeoffs that come up, usability is preferred over strict compliance to the
standard. Eventually, I hope to add some kind of plugin architecture, along with
some plugins to enable different functionality - e.g. both bittorrent and ethereum
contain incompatible implementations of kademlia. Independently customizable
elements are important in order to be compatible with different implementations.

## Contributors
Most of the meat of this project is in routing.rb and server.rb.
Routing manages the local routing table. Server contains all of the iterative
lookup and store methods.

Plugin Ideas/Future Work:
 - adding an identity layer, in which a private key is generated and the
corresponding public key is distributed as part the bootstrapping process. This
would then be stored in the routing table. The purpose of this would be to
prevent spartacus attacks, in which a node is guaranteed to be able to steal
the identity of another, simply by remaining connected for longer
 - Implementing pop/stun in order to connect through NAT.
 - Allow customizing the network message protocol used. e.g. we could
replace the druby message protocol with one that matches the UDP packets used by
other implementations.
 - Allow customizing the key generation algorithm used - e.g. the kademlia spec
uses 160 bit IDs, but Ethereum uses 256 bit IDs.
 - Implement some kind of checking whether nodes actually store the data. This
would help prevent sybil attacks. Nodes would be randomly checked to ensure
they respond with the data they were told to store. This would likely need to
come from a node other than the one that sent the data in the first place, to
avoid detecting the test.
 - Allow an alternate recursive routing structure, rather than the current
iterative structure. e.g. nodes forward messages rather than returning contacts.
This should help both with NAT traversal, but would hinder the self-healing proprties
of the network - meaning nodes would need other ways to obtain network information.
Probably should not be a default.
