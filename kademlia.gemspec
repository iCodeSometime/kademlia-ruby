require 'kademlia/version'

Gem::Specification.new do |s|
  s.name = 'kademlia'
  s.version = Kademlia::Version
  s.date = '2017-12-26'
  s.summary = 'A distributed hash table using the kademlia protocol.'
  s.description = 'A key value store that can be distributed across' +
  'millions of computers. Distance between nodes is calculated using the xor metric.'
  s.authors = ['Kenneth Cochran']
  s.email = 'TODO'
  # TODO: Rakefile, License, Readme, Gemfile
  s.files = Dir['lib/**/*'] + %w(
    kademlia.gemspec
  )
  s.homepage = 'TODO'
  s.license = 'MIT'
end
