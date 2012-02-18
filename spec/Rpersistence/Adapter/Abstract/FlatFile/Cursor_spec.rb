
if $__rpersistence__spec__development
  require_relative '../../../../../../../../lib/rpersistence.rb'
  require_relative '../../../../../lib/rpersistence-adapter-abstract-flat-file.rb'
else
  require 'rpersistence'
  require 'rpersistence-adapter-abstract-flat-file'
end

describe Rpersistence::Adapter::Abstract::FlatFile::Cursor do

  # we have to specify a serialization class; we use Marshal for our example
  class Rpersistence::Adapter::Abstract::FlatFile
    SerializationClass    =  Marshal
    SerializationMethod   =  :dump
    UnserializationMethod =  :load
    SerializationExtension = '.ruby_marshal.bin'
    FileContentsAreTextNotBinary = false
    StringifyClassnames = false
  end

  $__rpersistence__spec__adapter__ = ::Rpersistence::Adapter::Abstract::FlatFile.new( "/tmp/rpersistence-flat-file" )

  # adapter spec
  require_relative File.join( ::Rpersistence::Adapter.spec_location, 'Cursor_spec.rb' )

end
