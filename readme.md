# Installation
 `gem install Kademlia`

## Usage
```Ruby
# @todo Should we be able to choose a key? Or should it always be the hash

require 'kademlia'
# Stroing is asynchronous
key = Kademlia.store(File.read('filename'))
# Retrieving here is synchronous. Make sure your UI is in a separate thread.
file_content = Kademlia[key]
# Alternatively, provide a block to retrieve asynchronously
Kademlia[key] do |content|
  # Do something with the content
end
```

This is a fairly vanilla kademlia client.

It's meant to conform closely with the original whitepaper, but in any tradeoffs
that come up, usability is preferred over strict compliance to the standard.
Eventually, I hope to add some kind of plugin architecture, along with some
plugins to enable different functionality.

Examples:
  - adding an identity layer, in which a private key is generated and the
 corresponding public key is distributed as part the bootstrapping process. This
 would then be stored in the routing table. The purpose of this would be to
 prevent spartacus attacks, in which a node is guaranteed to be able to steal
 the identity of another, simply by remaining connected for longer
- Implementing pop/stun in order to connect through NAT.
