# Rpersistence::Adapter::FlatFile::Objects::Properties
#
# Flat Objects for Flat-File Adapter Module

#---------------------------------------------------------------------------------------------------------#
#--------------------------------  Flat-File Properties Adapter Module  ----------------------------------#
#---------------------------------------------------------------------------------------------------------#

module Rpersistence::Adapter::Abstract::FlatFile::Objects::Properties

	#############################
	#  put_complex_properties!  #
	#############################

	def put_complex_properties!( object, object_persistence_hash )

	  # iterate complex properties
	  # * remove flat declarations for property
	  # * declare complex
	  # * declare whether delete cascades
	  object.complex_properties.each do |this_complex_property, this_property_is_complex|

	    # each of these are complex properties - we write them to their location and remove them from the hash
	    # we store complex separately so we don't have to index which are complex
	    if this_property_is_complex

	      # remove any flat declarations for this property
	      file_location__flat_property = file_location__flat_property( object.persistence_bucket, object.persistence_id, this_complex_property )
	      if File.exists?( file_location__flat_property )
	        File.delete( file_location__flat_property )
	      end

	      # index that delete cascades for this object
	      if object.delete_cascades?( object.persistence_port, this_complex_property )
	        create_or_update_value_serialize_and_write( file_location__delete_cascades( object.persistence_bucket, object.persistence_id, this_complex_property ), true )
	      end

	      # write complex property
	      file_location__complex_property = file_location__complex_property( object.persistence_bucket, object.persistence_id, this_complex_property )
	      create_or_update_value_serialize_and_write( file_location__complex_property, object_persistence_hash[ this_complex_property ] )

	      # remove complex property from hash
	      object_persistence_hash.delete( this_complex_property )
    
	    end
    
	  end if object.complex_properties

	  return self

	end

	##########################
	#  put_flat_properties!  #
	##########################

	def put_flat_properties!( object, object_persistence_hash )

	  # iterate flat properties:
	  # * remove any complex declarations for this property
	  # * remove delete cascades for this property
	  object_persistence_hash.each do |this_flat_property, this_flat_property_value|

	    # remove any corresponding complex declaration
	    file_location__complex_property = file_location__complex_property( object.persistence_bucket, object.persistence_id, this_flat_property )
	    if File.exists?( file_location__complex_property )
	      File.delete( file_location__complex_property )
	    end

	    # remove any delete cascades
	    file_location__delete_cascades  =  file_location__delete_cascades( object.persistence_bucket, object.persistence_id, this_flat_property )
	    if File.exists?( file_location__delete_cascades )
	      File.delete( file_location__delete_cascades )
	    end

	    # write flat property
	    file_location__flat_property = file_location__flat_property( object.persistence_bucket, object.persistence_id, this_flat_property )
	    create_or_update_value_serialize_and_write( file_location__flat_property, this_flat_property_value )

	  end
  
	  return self
  
	end

end

