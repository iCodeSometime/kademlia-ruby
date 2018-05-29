# Installation
 `gem install Kademlia`

## Usage
```Ruby
# @todo Should we be able to choose a key? Or should it always be the hash

require 'kademlia'
# Storing is asynchronous
key, thread = Kad.store(File.read('filename'))
thread.join
# Retrieving here is synchronous. Make sure your UI is in a separate thread.
file_content = Kad[key]
# Alternatively, provide a block to retrieve asynchronously
thread = Kad[key] do |content|
  # Do something with the content
end
thread.join
```

This project makes no claim to be a strict implementation of the original paper,
and will not be compatible with implementations that are. Rather it is  a Ruby
flavored interpretation of the spec, passing around druby objects as the network
nodes, and calling commands directly on these, rather than sending UDP packets.


While it's meant to conform fairly closely with the original paper, in any
tradeoffs that come up, usability is preferred over strict compliance to the
standard. Eventually, I hope to add some kind of plugin architecture, along with
some plugins to enable different functionality.

## Contributing
Routing manages the local routing table, Server contains all of the iterative
lookup and store methods, and Node contains all of the methods to interact
directly with the information known by that particular node.

## Semantic Versioning Policy
While most will only use the methods in client.rb, this is provided as a
convenience for working with the DHT. We consider the API to include all
public methods in public classes. Private methods or classes could change at any
time, and should not be relied upon.
Until version 0.1.0, any part of the public API can change with any release.
Until version 1.0 is released, version numbers will be used as follows:

Any version that increments the patch number (0.0.x) will not change the public
API.
Any version that increments the minor number (0.x.0) will do one or several of:
 - add something to the public API
 - deprecate a portion of the public API
 - remove something that was previously deprecated.
Deprecated parts of the API will be removed in the very next minor release.
This is likely only relevant to specialized use cases. The basic store and retrieve
API described earlier in this document is not likely to change.

## Plugin Ideas/Future Work:
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
would help prevent spartacus attacks. Nodes would be randomly checked to ensure
they respond with the data they were told to store. This would likely need to
come from a node other than the one that sent the data in the first place, to
avoid detecting the test
 - Allow an alternate recursive routing structure, rather than the current
iterative structure. e.g. nodes forward messages rather than returning contacts.
This should help both with NAT traversal and adding an identity layer.
