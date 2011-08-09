# Rpersistence::Adapter::FlatFile::Serialization
#
# Serialization for Flat-File Adapter Module

#---------------------------------------------------------------------------------------------------------#
#------------------------------------  Flat-File Adapter Module  -----------------------------------------#
#---------------------------------------------------------------------------------------------------------#

module Rpersistence::Adapter::Abstract::FlatFile::Serialization

  ###########################################################################################################
      private ###############################################################################################
  ###########################################################################################################

  ################################################
  #  create_or_update_value_serialize_and_write  #
  ################################################

  def create_or_update_value_serialize_and_write( file_path, value )

    if value.is_a?( Class )
      value = Class::Name.new( value.to_s )
    end

    # open file, get data, perform action, rewrite data if appropriate, close file
    File.open( file_path, 'w' + ( self.class::FileContentsAreTextNotBinary ? 't' : 'b' ) ) do |file|
      serialized_value = self.class::SerializationClass.__send__( self.class::SerializationMethod, value )
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
      File.open( file_path, 'r+' + ( self.class::FileContentsAreTextNotBinary ? 't' : 'b' ) ) do |file|
        
        # get serializeled version of last persistence ID assigned
        serialized_value    =  file.read( file.size )
        unserialized_value  =  self.class::SerializationClass.__send__( self.class::UnserializationMethod, serialized_value ) if serialized_value

        if unserialized_value.is_a?( Class::Name )
          unserialized_value = unserialized_value.split( '::' ).inject( Object ) { |namespace, next_part| namespace.const_get( next_part ) }
        end

        # perform action if provided and write new data back
        if block_given?

          serialized_value = self.class::SerializationClass.__send__( self.class::SerializationMethod, yield( unserialized_value ) )
          if serialized_value.is_a?( Class )
            serialized_value = Class::Name.new( serialized_value.to_s )
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
