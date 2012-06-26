
require_relative '../../../lib/persistence/adapter/flat_file.rb'

describe ::Persistence::Adapter::FlatFile::Marshal do
  
  temp_test_path = "/tmp/persistence-adapter-flat_file"
  
  ::FileUtils.rm_rf( temp_test_path ) if ::Dir.exist?( temp_test_path )
  
  $__persistence__spec__adapter__ = ::Persistence::Adapter::FlatFile::Marshal.new( temp_test_path )

  # adapter spec
  require_relative File.join( ::Persistence::Adapter::Abstract.spec_location, 'Adapter_spec.rb' )
  
end
