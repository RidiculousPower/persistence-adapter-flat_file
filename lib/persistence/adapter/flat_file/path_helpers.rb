
module ::Persistence::Adapter::FlatFile::PathHelpers

  ##################################################################################################
      private ######################################################################################
  ##################################################################################################

  ######################################
  #  file__path_encoded_name_from_key  #
  ######################################

  def file__path_encoded_name_from_key( key )

    serialized_key = adapter_class::SerializationClass.__send__( adapter_class::SerializationMethod, key )

    return Base64.encode64( serialized_key )

  end

  ######################################
  #  file__key_from_path_encoded_name  #
  ######################################

  def file__key_from_path_encoded_name( digest )

    serialized_key = Base64.decode64( digest )
    unserialized_key = adapter_class::SerializationClass.__send__( adapter_class::UnserializationMethod, serialized_key )

    return unserialized_key

  end

  ##################################
  #  ensure_directory_path_exists  #
  ##################################

  def ensure_directory_path_exists( file_path )
    
    unless File.exists?( file_path )

      path_parts = File.expand_path( file_path ).split( '/' )
      # get rid of the first empty part from '/'
      path_parts.shift
      part = 0

      while part < path_parts.count

        directory = '/' + File.join( *path_parts[ 0 .. part ] )
        unless Dir.exist?( directory )
          Dir.mkdir( directory )
        end

        part += 1

      end

    end
    
    return self
  
  end

end
