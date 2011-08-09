# Rpersistence::Adapter::FlatFile::Locations
#
# Locations for Flat-File Adapter Module

#---------------------------------------------------------------------------------------------------------#
#------------------------------------  Flat-File Adapter Module  -----------------------------------------#
#---------------------------------------------------------------------------------------------------------#

require 'openssl'

module Rpersistence::Adapter::Abstract::FlatFile::Locations

  ###########################################################################################################
      private ###############################################################################################
  ###########################################################################################################

  ########################################### Path Helpers ##################################################

  ####################
  #  file_extension  #
  ####################
  
  def file_extension
    return '.ruby_flat_file.txt'
  end

  ##############################
  #  key_digest_for_file_path  #
  ##############################

	def key_digest_for_file_path( key )
    return OpenSSL::HMAC.hexdigest( OpenSSL::Digest::Digest.new( 'SHA1' ), 
                                    "key", 
                                    self.class::SerializationClass.__send__( self.class::SerializationMethod, key ) )
	end

  ##################################
  #  ensure_directory_path_exists  #
  ##################################

  def ensure_directory_path_exists( file_path )
    unless File.exists?( file_path )
      path_parts = file_path.split( '/' )
      part = 0
      while part < path_parts.count
        directory = '/' + path_parts[ 0 .. part ].join( '/' )
        Dir.mkdir( directory ) unless Dir.exist?( directory )
        part = part + 1
      end
    end
    return self
  end
  
  ######################################## Directory Locations ##############################################

  #######################################
  #  directory_location__ids_in_bucket  #
  #######################################
  
  # Global IDs:              <home_directory>/global_ids/bucket/
  def directory_location__ids_in_bucket( bucket )
		directory_location__ids_in_bucket = home_directory + '/global_ids/' + bucket.to_s + '/'
    ensure_directory_path_exists( directory_location__ids_in_bucket )
		return directory_location__ids_in_bucket
  end

  #######################################
  #  directory_location__ids_in_bucket  #
  #######################################
  
  # Bucket Index IDs:        <home_directory>/global_ids/bucket/
  def directory_location__ids_in_index( bucket, index )
		directory_location__ids_in_index = home_directory + '/indexes/ids_in_index/' + bucket.to_s + '/' + index.to_s + '/'
    ensure_directory_path_exists( directory_location__ids_in_index )
		return directory_location__ids_in_index
  end

  ##########################################
  #  directory_location__bucket_class_for_id  #
  ##########################################
  
  def directory_location__bucket_class_for_id
		directory_location__bucket_class_for_id = home_directory + '/bucket_class_for_id/'
    ensure_directory_path_exists( directory_location__bucket_class_for_id )
		return directory_location__bucket_class_for_id
  end

  ################################
  #  directory_location__object  #
  ################################

	def directory_location__object( bucket, global_id )
		directory_location__object = home_directory + '/objects/' + bucket.to_s + '/' + global_id.to_s + '/'
    ensure_directory_path_exists( directory_location__object )
    return directory_location__object
	end

  #########################################
  #  directory_location__flat_properties  #
  #########################################
  
  # Flat Property Directory:         <home_directory>/objects/bucket/ID/flat_properties
  def directory_location__flat_properties( bucket, global_id )
		directory_location__flat_properties = directory_location__object( bucket, global_id ) + '/flat_properties/'
    ensure_directory_path_exists( directory_location__flat_properties )
    return directory_location__flat_properties
  end

  ############################################
  #  directory_location__complex_properties  #
  ############################################

  # Complex Property Directory:     <home_directory>/objects/bucket/ID/complex_properties
  def directory_location__complex_properties( bucket, global_id )
		directory_location__complex_properties = home_directory + '/objects/' + bucket.to_s + '/' + global_id.to_s + '/complex_properties/'
    ensure_directory_path_exists( directory_location__complex_properties )
    return directory_location__complex_properties
  end

  #########################################
  #  directory_location__delete_cascades  #
  #########################################

  # Delete Cascades Directory:         <home_directory>/objects/bucket/ID/delete_cascades
  def directory_location__delete_cascades( bucket, global_id )
    directory_location__delete_cascades = home_directory + '/objects/' + bucket.to_s + '/' + global_id.to_s + '/delete_cascades/'
    ensure_directory_path_exists( directory_location__delete_cascades )
    return directory_location__delete_cascades
  end
  
  ###############################
  #  directory_location__index  #
  ###############################
  
  def directory_location__index( bucket, index )
		directory_location__index = home_directory + '/indexes/' + bucket.to_s + '/' + index.to_s + '/'
    ensure_directory_path_exists( directory_location__index )
		return directory_location__index
	end

  ##################################################
  #  directory_location__index_permits_duplicates  #
  ##################################################
  
  def directory_location__index_permits_duplicates
		directory_location__index_permits_duplicates = home_directory + '/indexes/'
    ensure_directory_path_exists( directory_location__index_permits_duplicates )
		return directory_location__index_permits_duplicates
	end
	
  ########################################### File Locations ################################################

  #######################################
  #  file_location__global_id_sequence  #
  #######################################
  
  # Global ID Sequence:      <home_directory>/global_id_sequence.ruby_serialize.txt
  def file_location__global_id_sequence  
    return home_directory + '/global_id_sequence' + file_extension
  end

  #############################################
  #  file_location__global_id_for_bucket_key  #
  #############################################
  
  # Global IDs:              <home_directory>/global_ids/bucket/key_digest_for_file_path.ruby_serialize.txt
  def file_location__global_id_for_bucket_key( bucket, key )
    key = key.to_s if key.is_a?( Class )
    return directory_location__ids_in_bucket( bucket ) + key_digest_for_file_path( key ) + file_extension
  end

  #########################################################
  #  file_location__index_key_for_bucket_index_global_id  #
  #########################################################
  
  # Global IDs:              <home_directory>/global_ids/bucket/key_digest_for_file_path.ruby_serialize.txt
  def file_location__index_key_for_bucket_index_global_id( bucket, index, global_id )
    return directory_location__ids_in_index( bucket, index ) + global_id.to_s + file_extension
  end

  ########################################
  #  file_location__bucket_class_for_id  #
  ########################################
  
  # Bucket/Key/Class:       <home_directory>/bucket_class/ID.ruby_serialize.txt
  def file_location__bucket_class_for_id( global_id )
    return directory_location__bucket_class_for_id + global_id.to_s + file_extension
  end

  ##################################
  #  file_location__flat_property  #
  ##################################
  
  # Flat Properties:         <home_directory>/objects/bucket/ID/flat_properties/property.ruby_serialize.txt
  def file_location__flat_property( bucket, global_id, property_name )
    return directory_location__flat_properties( bucket, global_id ) + property_name.to_s + file_extension
  end

  #####################################
  #  file_location__complex_property  #
  #####################################

  # Complex Properties:     <home_directory>/objects/bucket/ID/complex_properties/property.ruby_serialize.txt
  def file_location__complex_property( bucket, global_id, property_name )
    return directory_location__complex_properties( bucket, global_id ) + property_name.to_s + file_extension
  end

  ####################################
  #  file_location__delete_cascades  #
  ####################################

  # Delete Cascades:         <home_directory>/objects/bucket/ID/delete_cascades/property.ruby_serialize.txt
  def file_location__delete_cascades( bucket, global_id, property_name )
    return directory_location__delete_cascades( bucket, global_id ) + property_name.to_s + file_extension
  end

  ##########################
  #  file_location__index  #
  ##########################
  
  # Global ID:       				<home_directory>/indexes/bucket/key_digest_for_file_path.ruby_serialize.txt
  def file_location__index( bucket, index, key )
    key = key.to_s if key.is_a?( Class )
    return directory_location__index( bucket, index ) + key_digest_for_file_path( key ) + file_extension
  end

  #############################################
  #  file_location__index_permits_duplicates  #
  #############################################
  
  # Global ID:       				<home_directory>/indexes/bucket_name__index_name__permits_duplicates.ruby_serialize.txt
  def file_location__index_permits_duplicates( bucket, index )
    key = key.to_s if key.is_a?( Class )
    return directory_location__index_permits_duplicates + bucket.to_s + '__' + index.to_s + '__permits_duplicates' + file_extension
  end

  ############################################ Property Name ################################################

  ##################################
  #  property_name_from_file_path  #
  ##################################

  def property_name_from_file_path( file_path )
    # get basename instead of path
    file_basename = File.basename( file_path )
    return file_basename.slice( 0, file_basename.length - file_extension.length )
  end

end
