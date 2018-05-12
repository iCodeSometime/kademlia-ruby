require './lib/kademlia/version'

Gem::Specification.new do |s|
  s.name = 'kademlia'
  s.version = Kademlia::VERSION
  s.date = '2017-12-26'
  s.summary = 'A distributed hash table using the kademlia protocol.'
  s.description = 'A key value store that can be distributed across' +
  'millions of computers. Distance between nodes is calculated using the xor metric.'
  s.authors = ['Kenneth Cochran']
  s.email = 'TOD@g.co'
  # TODO: Rakefile, License, Readme, Gemfile
  s.files = Dir['lib/**/*'] + %w(
    kademlia.gemspec
  )
  s.homepage = 'https://TODO.com'
  s.license = 'MIT'
end
