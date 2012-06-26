
require 'base64'

#require 'persistence'
require_relative '../../../../persistence/lib/persistence.rb'

# namespaces that have to be declared ahead of time for proper load order
require_relative './namespaces'

# source file requires
require_relative './requires.rb'

class ::Persistence::Adapter::FlatFile

  include ::Persistence::Adapter::FlatFile::AdapterInterface
  
end
