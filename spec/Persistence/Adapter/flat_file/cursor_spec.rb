
require_relative '../../../../lib/persistence/adapter/flat_file.rb'

describe ::Persistence::Adapter::FlatFile::Cursor do

  # we have to specify a serialization class; we use Marshal for our example
  unless $__persistence__spec__development__initialized_flatfile
    class ::Persistence::Adapter::FlatFile
      SerializationClass    =  ::Marshal
      SerializationMethod   =  :dump
      UnserializationMethod =  :load
      SerializationExtension = '.ruby_marshal.bin'
      FileContentsAreTextNotBinary = false
      StringifyClassnames = false
    end
    $__persistence__spec__development__initialized_flatfile = true
  end

  temp_test_path = "/tmp/persistence-adapter-flat_file"
  
  ::FileUtils.rm_rf( temp_test_path ) if ::Dir.exist?( temp_test_path )
  
  $__persistence__spec__adapter__ = ::Persistence::Adapter::FlatFile.new( temp_test_path )

  # adapter spec
  require_relative File.join( ::Persistence::Adapter::Abstract.spec_location, 'Cursor_spec.rb' )

end
