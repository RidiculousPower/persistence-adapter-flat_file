
if $__persistence__spec__development__
  require_relative '../../../../../../../../lib/persistence.rb'
else
  require 'persistence'
end

describe ::Persistence::Adapter::YamlFlatFile do
  
  temp_test_path = "/tmp/persistence-adapter-flat_file"
  
  ::FileUtils.rm_rf( temp_test_path ) if ::Dir.exist?( temp_test_path )
  
  $__persistence__spec__adapter__ = ::Persistence::Adapter::FlatFile::YAML.new( temp_test_path )

  # adapter spec
  require_relative File.join( ::Persistence::Adapter::Abstract.spec_location, 'Cursor_spec.rb' )
  
end
