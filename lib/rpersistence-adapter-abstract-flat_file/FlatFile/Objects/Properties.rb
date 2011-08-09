# Rpersistence::Adapter::FlatFile::Objects::Properties
#
# Flat Objects for Flat-File Adapter Module

#---------------------------------------------------------------------------------------------------------#
#--------------------------------  Flat-File Properties Adapter Module  ----------------------------------#
#---------------------------------------------------------------------------------------------------------#

module Rpersistence::Adapter::Abstract::FlatFile::Objects::Properties

  ###################
  #  put_property!  #
  ###################

  def put_property!( object, property_name, property_value )
    
		if object.is_complex_object?( property_name )
      create_or_update_value_serialize_and_write( file_location__complex_property( object.persistence_bucket, object.persistence_id, property_name ), property_value )
      create_or_update_value_serialize_and_write( file_location__delete_cascades( object.persistence_bucket, object.persistence_id, property_name ), true )
    else
      create_or_update_value_serialize_and_write( file_location__flat_property( object.persistence_bucket, object.persistence_id, property_name ), property_value )      
      create_or_update_value_serialize_and_write( file_location__delete_cascades( object.persistence_bucket, object.persistence_id, property_name ), false )
    end
		
    return self
  end

  ##################
  #  get_property  #
  ##################

  def get_property( object, property_name )
    property_value = nil
    if object.is_complex_object?( property_name )
      sub_object_global_id   = open_read_unserialize_and_close( file_location__complex_property( object.persistence_bucket, object.persistence_id, property_name ) )
      sub_object_bucket = get_bucket_for_object_id( sub_object_global_id )      
      sub_object_klass  = get_class_for_object_id( sub_object_global_id )      
      property_value  =  get_object( sub_object_global_id, sub_object_bucket )
    else
      property_value  =  open_read_unserialize_and_close( file_location__flat_property( object.persistence_bucket, object.persistence_id, property_name ) )      
    end
    return property_value
  end

  ######################
  #  delete_property!  #
  ######################

  def delete_property!( object, property_name )

    cascading_status_file_path  =  file_location__delete_cascades( object.persistence_bucket, object.persistence_id, property_name )
    
    property_location = nil
    
    # delete cascading status for any properties
    if open_read_unserialize_and_close( cascading_status_file_path )
      file_location__complex_property  =  file_location__complex_property( object.persistence_bucket, object.persistence_id, property_name )
      sub_object_global_id  =  object.instance_variable_get( property_name )
      sub_object_bucket = get_bucket_for_object_id( sub_object_global_id )      
      sub_object_klass  = get_class_for_object_id( sub_object_global_id )      
      delete_object!( sub_object_global_id, sub_object_bucket )
      property_location = file_location__complex_property( object.persistence_bucket, object.persistence_id, property_name )
    else
      property_location = file_location__flat_property( object.persistence_bucket, object.persistence_id, property_name )
    end

    # delete this cascading status
    File.delete( cascading_status_file_path )

    # delete this property
    File.delete( property_location )

    return self

  end

  #######################
  #  complex_property?  #
  #######################

  def complex_property?( object, property_name )
    return open_read_unserialize_and_close( file_location__complex_property( object.persistence_bucket, object.persistence_id, property_name ) )
  end
	
end

