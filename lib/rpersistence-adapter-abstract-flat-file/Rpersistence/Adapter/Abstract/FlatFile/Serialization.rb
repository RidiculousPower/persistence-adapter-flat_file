# Rpersistence::Adapter::FlatFile::Serialization
#
# Serialization for Flat-File Adapter Module

#---------------------------------------------------------------------------------------------------------#
#------------------------------------  Flat-File Adapter Module  -----------------------------------------#
#---------------------------------------------------------------------------------------------------------#

module Rpersistence::Adapter::Abstract::FlatFile::Serialization

  ##################################################################################################
      private ######################################################################################
  ##################################################################################################

  ################################################
  #  create_or_update_value_serialize_and_write  #
  ################################################

  def create_or_update_value_serialize_and_write( file_path, value )

    if value.is_a?( Class )
      value = ::Rpersistence::Adapter::Abstract::FlatFile::ClassName.new( value.to_s )
    end

    # open file, get data, perform action, rewrite data if appropriate, close file
    mode = 'w' + ( adapter_class::FileContentsAreTextNotBinary ? 't' : 'b' )
    File.open( file_path, mode ) do |file|
      serialized_value = adapter_class::SerializationClass.__send__( adapter_class::SerializationMethod, value )
      file.write( serialized_value )
    end
    
    return self
    
  end
  
  #####################################
  #  open_read_unserialize_and_close  #
  #####################################

  def open_read_unserialize_and_close( file_path )
    
    return open_read_unserialize_perform_action_serialize_write_and_close( file_path )
  
  end
  
  ####################################################################
  #  open_read_unserialize_perform_action_serialize_write_and_close  #
  ####################################################################

  def open_read_unserialize_perform_action_serialize_write_and_close( file_path )

    unserialized_value = nil

    # if we don't have a file we obviously don't have a value - return nil
    if File.exists?( file_path )

      # open file, get data, perform action, rewrite data if appropriate, close file
      mode = 'r+' + ( adapter_class::FileContentsAreTextNotBinary ? 't' : 'b' )
      File.open( file_path, mode ) do |file|
        
        # get serializeled version of last persistence ID assigned
        serialized_value    =  file.read( file.size )
        if serialized_value
          unserialized_value = adapter_class::SerializationClass.__send__( adapter_class::UnserializationMethod, serialized_value )
        end
        
        if unserialized_value.is_a?( ::Rpersistence::Adapter::Abstract::FlatFile::ClassName )
          unserialized_value = unserialized_value.split( '::' ).inject( Object ) { |namespace, next_part| namespace.const_get( next_part ) }
        end

        # perform action if provided and write new data back
        if block_given?

          serialized_value = adapter_class::SerializationClass.__send__( adapter_class::SerializationMethod, yield( unserialized_value ) )
          if serialized_value.is_a?( Class )
            serialized_value = ::Rpersistence::Adapter::Abstract::FlatFile::ClassName.new( serialized_value.to_s )
          end
          file.rewind
          file.truncate( 0 )
          file.write( serialized_value )

        end

      end

    end
    
    return unserialized_value
    
  end

end
