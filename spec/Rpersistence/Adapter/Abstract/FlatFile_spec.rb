$__rpersistence__spec__development = true

if $__rpersistence__spec__development
  require_relative '../../../../../../../lib/rpersistence.rb'
  require_relative '../../../../lib/rpersistence-adapter-abstract-flat_file.rb'
else
  require 'rpersistence'
  require 'rpersistence-adapter-abstract-flat_file'
end

describe Rpersistence::Adapter::Abstract::FlatFile do

  # we have to specify a serialization class; we use Marshal for our example
  class Rpersistence::Adapter::Abstract::FlatFile
    SerializationClass    =  Marshal
    SerializationMethod   =  :dump
    UnserializationMethod =  :load
    SerializationExtension = '.ruby_marshal.bin'
    FileContentsAreTextNotBinary = false
    StringifyClassnames = false
  end

  $__rpersistence__spec__adapter__ = ::Rpersistence::Adapter::Abstract::FlatFile.new( "/tmp/rpersistence-flat_file" )

  # adapter spec
  require_relative File.join( ::Rpersistence::Adapter.spec_location, 'Adapter_spec.rb' )

end
