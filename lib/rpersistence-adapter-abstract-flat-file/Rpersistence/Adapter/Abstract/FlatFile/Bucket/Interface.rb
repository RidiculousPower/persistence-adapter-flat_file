
module Rpersistence::Adapter::Abstract::FlatFile::Bucket::Interface

  include Rpersistence::Adapter::Abstract::Interface::PrimaryKey::Simple
  
  include Rpersistence::Adapter::Abstract::FlatFile::PathHelpers
  include Rpersistence::Adapter::Abstract::FlatFile::Serialization

  attr_accessor :name, :parent_adapter

  ################
  #  initialize  #
  ################

  def initialize( parent_adapter, bucket_name )
    
    @parent_adapter = parent_adapter
		@name = bucket_name

    # storage for index objects
    @indexes = { }
		
  end

  ###################
  #  adapter_class  #
  ###################
  
  def adapter_class
    
    return @parent_adapter.class
    
  end

  ############
  #  cursor  #
  ############

  def cursor
    
    return ::Rpersistence::Adapter::Abstract::FlatFile::Cursor.new( self, nil )

  end

  ###########
  #  count  #
  ###########
  
  def count
    
    glob_list = Dir.glob( File.join( directory__ids_in_bucket, '*' ) )
    
    return glob_list.count
    
  end

  #################
  #  put_object!  #
  #################

  # must be recoverable by information in the object
  # we currently use class and persistence key
  def put_object!( object )
    
    @parent_adapter.ensure_object_has_globally_unique_id( object )
    
    # write ID to bucket's contents
    file__ids_in_bucket = file__ids_in_bucket( object.persistence_id )
    create_or_update_value_serialize_and_write( file__ids_in_bucket, object.persistence_id )
    
    object_persistence_hash = object.persistence_hash_to_port

	  # iterate flat properties:
	  # * remove delete cascades for this attribute
	  object_persistence_hash.each do |this_attribute, this_attribute_value|

	    file__attribute = file__attributes( object.persistence_id, this_attribute )

	    create_or_update_value_serialize_and_write( file__attribute, this_attribute_value )

	  end

    return object.persistence_id

  end

  ################
  #  get_object  #
  ################

  def get_object( global_id )

    persistence_hash_from_port = { }

    # iterate directory of flat objects and unload into hash
    Dir[ File.join( directory__attributes( global_id ), '*' ) ].each do |this_file|

      # unserialize contents of file at path for flat attribute value
      this_attribute = attribute_name_from_file_path( this_file )
      this_attribute = this_attribute.to_sym if this_attribute
      this_value = open_read_unserialize_and_close( this_file )

      persistence_hash_from_port[ this_attribute ] = this_value

    end
    
    return persistence_hash_from_port.empty? ? nil : persistence_hash_from_port

  end
  
  ####################
  #  delete_object!  #
  ####################

  def delete_object!( global_id )

    # delete flat properties
    Dir[ File.join( directory__attributes( global_id ), '*' ) ].each do |this_file|

      File.delete( this_file )

    end

    file__ids_in_bucket = file__ids_in_bucket( global_id )
    File.delete( file__ids_in_bucket )

    @parent_adapter.delete_bucket_for_object_id( global_id )      
    @parent_adapter.delete_class_for_object_id( global_id )      

    return self

  end

  ####################
  #  put_attribute!  #
  ####################

  def put_attribute!( global_id, attribute_name, value )
    
    file__attribute = file__attributes( global_id, attribute_name )
    
    create_or_update_value_serialize_and_write( file__attribute, value )      
		
    return self

  end

  ###################
  #  get_attribute  #
  ###################

  def get_attribute( global_id, attribute_name )
    
    file__attribute = file__attributes( global_id, attribute_name )
    
    return open_read_unserialize_and_close( file__attribute )

  end

  #######################
  #  delete_attribute!  #
  #######################

  def delete_attribute!( global_id, attribute_name )

    file__attribute = file__attributes( global_id, attribute_name )

    # delete this attribute
    File.delete( file__attribute )

  end

  ##################
  #  create_index  #
  ##################
  
  def create_index( index_name, permits_duplicates )
    
    unless ( permits_duplicates_value = permits_duplicates?( index_name ) ).nil?
      
			if ! permits_duplicates_value != ! permits_duplicates
	      raise 'Index on :' + index_name.to_s + ' already exists and ' + 
	            ( permits_duplicates ? 'does not permit' : 'permits' ) + ' duplicates, which conflicts.'
			end

    else

      file__permits_duplicates = file__index_permits_duplicates( index_name )

  		create_or_update_value_serialize_and_write( file__permits_duplicates, 
  																								permits_duplicates )

    end

    # create/instantiate the index
    index_instance = Rpersistence::Adapter::Abstract::FlatFile::Bucket::Index.new( index_name,
                                                                                   self,
                                                                                   permits_duplicates )

    # store index instance
    @indexes[ index_name ] = index_instance

    return index_instance

  end

  ###########
  #  index  #
  ###########
  
  def index( index_name )

    return @indexes[ index_name ]

  end

  ################
  #  has_index?  #
  ################

	def has_index?( index_name )
	  
	  return @indexes.has_key?( index_name )

  end

  #########################
  #  permits_duplicates?  #
  #########################

	def permits_duplicates?( index_name )
	  
	  file__permits_duplicates = file__index_permits_duplicates( index_name )
	  
	  return open_read_unserialize_and_close( file__permits_duplicates )

  end

  ##################
  #  delete_index  #
  ##################
  
  def delete_index( index_name )

    index_instance = @indexes.delete( index_name )
    
    index_instance.delete
    
		# delete permits_duplicates
		File.delete( file__index_permits_duplicates( index_name ) )

		return self

  end

  ##################################################################################################
      private ######################################################################################
  ##################################################################################################

  #######################
  #  directory__object  #
  #######################

	def directory__object( global_id )

		directory__object = File.join( @parent_adapter.home_directory,
		                               'objects',
		                               @name.to_s,
		                               global_id.to_s )
		                               
    ensure_directory_path_exists( directory__object )

    return directory__object

	end

  ###########################
  #  directory__attributes  #
  ###########################
  
  # Flat Property Directory:         <home_directory>/objects/bucket/ID/flat_properties
  def directory__attributes( global_id )

		directory__attributes = File.join( directory__object( global_id ),
		                                   'attributes' )

    ensure_directory_path_exists( directory__attributes )

    return directory__attributes

  end

  #########################################
  #  directory__index_permits_duplicates  #
  #########################################
  
  def directory__index_permits_duplicates

		directory__index_permits_duplicates = File.join( @parent_adapter.home_directory, 'indexes' )

    ensure_directory_path_exists( directory__index_permits_duplicates )

		return directory__index_permits_duplicates

	end
  
  ##############################
  #  directory__ids_in_bucket  #
  ##############################
  
  # Global IDs:              <home_directory>/global_ids/bucket/
  def directory__ids_in_bucket
    
		directory__ids_in_bucket = File.join( @parent_adapter.home_directory,
		                                      'global_ids',
		                                      @name.to_s )
    
    ensure_directory_path_exists( directory__ids_in_bucket )
		
		return directory__ids_in_bucket

  end
  
  #########################
  #  file__ids_in_bucket  #
  #########################
  
  def file__ids_in_bucket( global_id )
    
    return File.join( directory__ids_in_bucket, 
                      global_id.to_s + @parent_adapter.class::SerializationExtension )
    
  end
  
  ######################
  #  file__attributes  #
  ######################
  
  # Flat Attributes:         <home_directory>/objects/bucket/ID/flat_properties/attribute.ruby_serialize.txt
  def file__attributes( global_id, attribute_name )

    return File.join( directory__attributes( global_id ),
                      attribute_name.to_s + @parent_adapter.class::SerializationExtension )

  end

  ####################################
  #  file__index_permits_duplicates  #
  ####################################
  
  # Global ID:       				<home_directory>/indexes/bucket_name__index_name__permits_duplicates.ruby_serialize.txt
  def file__index_permits_duplicates( index_name )

    key = key.to_s if key.is_a?( Class )

    return File.join( directory__index_permits_duplicates,
                      @name.to_s + '__' + index_name.to_s + '__permits_duplicates' + @parent_adapter.class::SerializationExtension )

  end

  ###################################
  #  attribute_name_from_file_path  #
  ###################################

  def attribute_name_from_file_path( file_path )

    # get basename instead of path
    file_basename = File.basename( file_path )

    return file_basename.slice( 0, file_basename.length - @parent_adapter.class::SerializationExtension.length )

  end

end
