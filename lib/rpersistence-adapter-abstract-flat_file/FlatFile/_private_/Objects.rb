# Rpersistence::Adapter::FlatFile::Objects
#
# Objects for Flat-File Adapter Module

#---------------------------------------------------------------------------------------------------------#
#----------------------------------  Flat-File Objects Adapter Module  -----------------------------------#
#---------------------------------------------------------------------------------------------------------#

module Rpersistence::Adapter::Abstract::FlatFile::Objects

  ###########################################################################################################
      private ###############################################################################################
  ###########################################################################################################

  ##########################################
  #  ensure_object_has_globally_unique_id  #
  ##########################################
  
  def ensure_object_has_globally_unique_id( object )

    unless object.persistence_id
              
      # iterate the sequence by 1 and use the ID
      object.persistence_id = iterate_id_sequence
      
      # store bucket, key, class for ID
      store_bucket_klass_for_id( object.persistence_bucket, object.class, object.persistence_id )

    end    

    return object.persistence_id

  end

  #########################
  #  iterate_id_sequence  #
  #########################
  
  def iterate_id_sequence
    
    new_object_id = nil

    open_read_unserialize_perform_action_serialize_write_and_close( file_location__global_id_sequence ) do |last_persistence_id|
      # iterate for persistence ID
      last_persistence_id  = last_persistence_id + 1
      # assign to object
      new_object_id        =  last_persistence_id
    end
    
    return new_object_id
    
  end
  
  ###############################
  #  store_bucket_klass_for_id  #
  ###############################
  
  def store_bucket_klass_for_id( bucket, klass, global_id )

    File.open( file_location__bucket_class_for_id( global_id ), 'w+' + ( self.class::FileContentsAreTextNotBinary ? 't' : 'b' ) ) do |file|
      bucket_class = self.class::SerializationClass.__send__( self.class::SerializationMethod, [ bucket, self.class::StringifyClassnames ? klass.to_s : klass ] )
      file.write( bucket_class )
    end
    
  end

end
