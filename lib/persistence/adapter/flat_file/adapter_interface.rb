
module ::Persistence::Adapter::FlatFile::AdapterInterface

  include ::Persistence::Adapter::Abstract::EnableDisable
  include ::Persistence::Adapter::Abstract::PrimaryKey::IDPropertyString

  include ::Persistence::Adapter::FlatFile::PathHelpers
  include ::Persistence::Adapter::FlatFile::Serialization

  Delimiter = '.'

  attr_accessor :parent_bucket
  
  ################
  #  initialize  #
  ################

  def initialize( home_directory )
    
    super( home_directory )

    @buckets = { }

    # make sure we have a sequence
    unless File.exists?( file__global_id_sequence )
      create_or_update_value_serialize_and_write( file__global_id_sequence, -1 )
    end
    
  end
  
  ###################
  #  adapter_class  #
  ###################
  
  def adapter_class
    
    return self.class
    
  end

  ########################
  #  persistence_bucket  #
  ########################

  def persistence_bucket( bucket_name )
    
    bucket_instance = nil

    unless bucket_instance = @buckets[ bucket_name ]
      bucket_instance = ::Persistence::Adapter::FlatFile::Bucket.new( self, bucket_name )
      @buckets[ bucket_name ] = bucket_instance
    end

    return bucket_instance

  end

  ###################################
  #  get_bucket_name_for_object_id  #
  ###################################

  def get_bucket_name_for_object_id( global_id )
    
    file__bucket = file__bucket_name_for_id( global_id )
    
    return open_read_unserialize_and_close( file__bucket )

  end

  #############################
  #  get_class_for_object_id  #
  #############################

  def get_class_for_object_id( global_id )
    
    file__class = file__class_for_id( global_id )
    
    return open_read_unserialize_and_close( file__class )

  end

  #################################
  #  delete_bucket_for_object_id  #
  #################################

  def delete_bucket_for_object_id( global_id )

    file__bucket = file__bucket_name_for_id( global_id )
    
    File.delete( file__bucket )
    
  end

  ################################
  #  delete_class_for_object_id  #
  ################################

  def delete_class_for_object_id( global_id )

    file__class = file__class_for_id( global_id )

    File.delete( file__class )
  
  end

  ##########################################
  #  ensure_object_has_globally_unique_id  #
  ##########################################
  
  def ensure_object_has_globally_unique_id( object )

    unless global_id = object.persistence_id
              
      # iterate the sequence by 1 and use the ID
      object.persistence_id = global_id = iterate_id_sequence
      
      # store bucket name for ID
      store_bucket_name_for_id( object.persistence_bucket.name, global_id )

      # store class for ID
      store_class_for_id( object.class, global_id )

    end    

    return global_id

  end

  ##################################################################################################
      private ######################################################################################
  ##################################################################################################

  #########################
  #  iterate_id_sequence  #
  #########################
  
  def iterate_id_sequence
    
    new_object_id = nil

    open_read_unserialize_perform_action_serialize_write_and_close( file__global_id_sequence ) do |last_persistence_id|
      
      # iterate for persistence ID - "last_persistence_id" is the last ID used
      last_persistence_id = last_persistence_id + 1
      
      # assign to object
      new_object_id = last_persistence_id
      
    end
    
    return new_object_id
    
  end

  ##############################
  #  store_bucket_name_for_id  #
  ##############################
  
  def store_bucket_name_for_id( bucket_name, global_id )

    file__bucket_name = file__bucket_name_for_id( global_id )
    
    create_or_update_value_serialize_and_write( file__bucket_name, bucket_name )
        
  end
  
  ########################
  #  store_class_for_id  #
  ########################
  
  def store_class_for_id( klass, global_id )

    file__class = file__class_for_id( global_id )
    
    serialize_as_class = self.class::StringifyClassnames ? klass.to_s : klass

    create_or_update_value_serialize_and_write( file__class, serialize_as_class )
    
  end

  ###################################
  #  directory__bucket_name_for_id  #
  ###################################
  
  def directory__bucket_name_for_id

    directory__bucket_name_for_id = File.join( home_directory, 'bucket_name_for_id' )
                                               
    ensure_directory_path_exists( directory__bucket_name_for_id )

    return directory__bucket_name_for_id

  end

  #############################
  #  directory__class_for_id  #
  #############################
  
  def directory__class_for_id

    directory__class_for_id = File.join( home_directory, 'class_for_id' )
                                         
    ensure_directory_path_exists( directory__class_for_id )

    return directory__class_for_id

  end

  ##############################
  #  file__global_id_sequence  #
  ##############################
  
  # Global ID Sequence:      <home_directory>/global_id_sequence.ruby_serialize.txt
  def file__global_id_sequence  

    return File.join( home_directory,
                      'global_id_sequence' + self.class::SerializationExtension )

  end

  ##############################
  #  file__bucket_name_for_id  #
  ##############################
  
  # Bucket/key/class:       <home_directory>/bucket_class/id.ruby_serialize.txt
  def file__bucket_name_for_id( global_id )

    return File.join( directory__bucket_name_for_id,
                      global_id.to_s + self.class::SerializationExtension )

  end

  ########################
  #  file__class_for_id  #
  ########################
  
  # Bucket/key/class:       <home_directory>/bucket_class/id.ruby_serialize.txt
  def file__class_for_id( global_id )

    return File.join( directory__class_for_id,
                      global_id.to_s + self.class::SerializationExtension )

  end

end

