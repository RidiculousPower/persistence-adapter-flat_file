# Rpersistence::Adapter::FlatFile::Objects
#
# Objects for Flat-File Adapter Module

#---------------------------------------------------------------------------------------------------------#
#----------------------------------  Flat-File Objects Adapter Module  -----------------------------------#
#---------------------------------------------------------------------------------------------------------#

module Rpersistence::Adapter::Abstract::FlatFile::Objects

  #################
  #  put_object!  #
  #################

  # must be recoverable by information in the object
  # we currently use class and persistence key
  def put_object!( object )
    
    ensure_object_has_globally_unique_id( object )
    object_persistence_hash = object.persistence_hash_to_port

    put_complex_properties!( object, object_persistence_hash )
    put_flat_properties!( object, object_persistence_hash )

    return object.persistence_id

  end

  ################
  #  get_object  #
  ################

  def get_object( global_id, bucket )

    persistence_hash_from_port  =  Hash.new

    # iterate directory of flat objects and unload into hash
    files = Dir.glob( directory_location__flat_properties( bucket, global_id ) + '/*' )
    files.each do |this_file|
      # unserialize contents of file at path for flat property value
      flat_key = property_name_from_file_path( this_file )
      flat_key = flat_key.to_sym if flat_key
      persistence_hash_from_port[ flat_key ] = open_read_unserialize_and_close( this_file )
    end
    
    # iterate directory of complex object IDs and persist into hash
    files = Dir.glob( directory_location__complex_properties( bucket, global_id ) + '/*' )
    files.each do |this_file|
      # get sub-object ID from file
      sub_object_global_id  =  open_read_unserialize_and_close( this_file )
      # get bucket, key, class for sub-object
      sub_object_bucket = get_bucket_for_object_id( sub_object_global_id )      
      sub_object_klass  = get_class_for_object_id( sub_object_global_id )      
      persistence_hash_from_port[ property_name_from_file_path( this_file ).to_sym ]  = [ :__rpersistence__complex_object__, 
																																													sub_object_klass, 
																																													get_object( sub_object_global_id, sub_object_bucket ) ]
    end

    return persistence_hash_from_port

  end
  
  ####################
  #  delete_object!  #
  ####################

  def delete_object!( global_id, bucket )

    # delete flat properties
    files = Dir.glob( directory_location__flat_properties( bucket, global_id ) + '/*' )
    files.each do |this_file|
      File.delete( this_file )
    end
    
    # delete complex properties and any corresponding complex objects that cascade
    Dir[ directory_location__complex_properties( bucket, global_id ) + '/*' ].each do |this_file|

      sub_object_global_id  =  open_read_unserialize_and_close( this_file )

      sub_object_bucket = get_bucket_for_object_id( sub_object_global_id )      
      sub_object_klass  = get_class_for_object_id( sub_object_global_id )      

      cascading_status_file_path  =  directory_location__delete_cascades( sub_object_bucket, sub_object_global_id ) + '/' + File.basename( this_file )

      # delete cascading status for any properties
      if open_read_unserialize_and_close( cascading_status_file_path )
        delete_object!( sub_object_global_id )
      end

      # delete this cascading status
      File.delete( cascading_status_file_path )

      # delete this property
      File.delete( this_file )

    end

    # delete ID
    File.delete( file_location__bucket_class_for_id( global_id ) )

    return self

  end
  	
end

