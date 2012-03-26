
if $__persistence__spec__development__
  require_relative '../../../../../../../lib/persistence.rb'
  require_relative '../../../../lib/persistence-adapter-abstract-flat-file.rb'
else
  require 'persistence'
  require 'persistence-adapter-abstract-flat-file'
end

describe ::Persistence::Adapter::Abstract::FlatFile do

  # we have to specify a serialization class; we use Marshal for our example
  unless $__persistence__spec__development__initialized_flatfile
    class ::Persistence::Adapter::Abstract::FlatFile
      SerializationClass    =  Marshal
      SerializationMethod   =  :dump
      UnserializationMethod =  :load
      SerializationExtension = '.ruby_marshal.bin'
      FileContentsAreTextNotBinary = false
      StringifyClassnames = false
    end
    $__persistence__spec__development__initialized_flatfile = true
  end
  
  $__persistence__spec__adapter__ = ::Persistence::Adapter::Abstract::FlatFile.new( "/tmp/persistence-flat-file" )

  # adapter spec
  require_relative File.join( ::Persistence::Adapter.spec_location, 'Adapter_spec.rb' )

end
