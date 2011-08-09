# Rpersistence::Adapter::FlatFile::ID
#
# IDs for Flat-File Adapter Module

#---------------------------------------------------------------------------------------------------------#
#------------------------------------  Flat-File ID Adapter Module  --------------------------------------#
#---------------------------------------------------------------------------------------------------------#

module Rpersistence::Adapter::Abstract::FlatFile::ID

  ############################################
  #  get_object_id_for_bucket_index_and_key  #
  ############################################

  def get_object_id_for_bucket_index_and_key( bucket, index, key )
		object_id = nil
		if index
			object_id = open_read_unserialize_and_close( file_location__index( bucket, index, key ) )
		else
			object_id = open_read_unserialize_and_close( file_location__global_id_for_bucket_key( bucket, key ) )
		end
    return object_id
  end

  ####################################
  #  get_bucket_class_for_object_id  #
  ####################################

  def get_bucket_class_for_object_id( global_id )

    bucket_class = open_read_unserialize_and_close( file_location__bucket_class_for_id( global_id ) )

    return bucket_class
  end

  ########################################
  #  persistence_key_exists_for_index?  #
  ########################################

  def persistence_key_exists_for_index?( bucket, index, key )
    return ( get_object_id_for_bucket_index_and_key( bucket, index, key ) ? true : false )
  end

end
