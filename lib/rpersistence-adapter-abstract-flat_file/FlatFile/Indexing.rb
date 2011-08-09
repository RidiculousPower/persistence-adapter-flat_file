# Rpersistence::Adapter::FlatFile::Indexing
#
# Indexing for Flat-File Adapter Module

#---------------------------------------------------------------------------------------------------------#
#--------------------------------  Flat-File Indexing Adapter Module  ------------------------------------#
#---------------------------------------------------------------------------------------------------------#

module Rpersistence::Adapter::Abstract::FlatFile::Indexing

	include Rpersistence::Adapter::Abstract::FlatFile::Locations
	include Rpersistence::Adapter::Abstract::FlatFile::Serialization

  ##################
  #  create_index  #
  ##################
  
  def create_index( klass, attribute, permits_duplicates )
		create_or_update_value_serialize_and_write( file_location__index_permits_duplicates( klass.instance_persistence_bucket, attribute ), 
																								permits_duplicates )
		return self
  end

  ################
  #  has_index?  #
  ################

	def has_index?( klass, index )
	  return File.exists?( file_location__index_permits_duplicates( klass.instance_persistence_bucket, index ) )
  end

  ###############################
  #  index_permits_duplicates?  #
  ###############################

	def index_permits_duplicates?( klass, index )
	  return open_read_unserialize_and_close( file_location__index_permits_duplicates( klass.instance_persistence_bucket, index ) )
  end

  ############################
  #  index_property_for_object  #
  ############################
  
  def index_property_for_object( object, attribute, value )

    file_path = file_location__index( object.persistence_bucket, attribute, value )

    if index_permits_duplicates?( object.class, attribute )

      if File.exists?( file_path )
        open_read_unserialize_perform_action_serialize_write_and_close( file_path ) do |ids|
          ids.push( object.persistence_id ).sort.uniq
        end
      else
    		# index value => ID
    		create_or_update_value_serialize_and_write( file_path, [ object.persistence_id ] )
      end
            
    else
      
      if File.exists?( file_path )
        # check to make sure that we do not already have an index value with a different ID
        open_read_unserialize_perform_action_serialize_write_and_close( file_path ) do |id|
          # If we already have a file for this index value and it holds this object's id,
          # then we don't need to do anything.
          # Otherwise we have a duplicate key in a unique index, which is a problem.
          unless id == object.persistence_id
            raise Rpersistence::Exceptions::DuplicateViolatesUniqueIndexError.new( 
                  'Attempt to create index on attribute :' + attribute.to_s + 
                  ' would create duplicates in a unique index.' )
          end
        end
      else
    		# index value => ID
    		create_or_update_value_serialize_and_write( file_path, object.persistence_id )
      end
      
    end

		# index ID => value for updating keys if they change
		object_index_location = file_location__index_key_for_bucket_index_global_id( object.persistence_bucket, 
		                                                                             attribute, 
		                                                                             object.persistence_id )
		create_or_update_value_serialize_and_write( object_index_location, 
																								value )
    
		return self

  end

  ##################
  #  delete_index  #
  ##################
  
  def delete_index( klass, index )
		directories = [ directory_location__index( klass.instance_persistence_bucket, index ),
										directory_location__ids_in_index( klass.instance_persistence_bucket, index ) ]
		# delete permits_duplicates
		File.delete( file_location__index_permits_duplicates( klass.instance_persistence_bucket, index ) )
    # delete index data
		directories.each do |this_directory|
			# delete all indexed contents
			Dir[ this_directory + '*' ].each do |this_file|
			  File.delete( this_file )
			end
			# delete index
			Dir.delete( this_directory )
		end
		return self
  end

  #############################
  #  delete_index_for_object  #
  #############################

	def delete_index_for_object( bucket, index, global_id )
		key = open_read_unserialize_and_close( file_location__index_key_for_bucket_index_global_id( bucket, index, global_id ) )
		files = [ file_location__index_key_for_bucket_index_global_id( bucket, index, global_id ),
							file_location__index( bucket, index, key ) ]
		files.each do |this_file|
			File.delete( this_file )
		end
    return self
	end
	
end
