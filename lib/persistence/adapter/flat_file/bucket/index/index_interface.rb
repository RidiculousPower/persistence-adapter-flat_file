
module ::Persistence::Adapter::FlatFile::Bucket::Index::IndexInterface

  include ::Persistence::Adapter::FlatFile::PathHelpers
  include ::Persistence::Adapter::FlatFile::Serialization
  
  ################
  #  initialize  #
  ################

  def initialize( index_name, parent_bucket, permits_duplicates )

    @name = index_name

    @parent_bucket = parent_bucket

    @permits_duplicates = permits_duplicates
    
  end

  ###################
  #  adapter_class  #
  ###################
  
  def adapter_class
    
    return @parent_bucket.parent_adapter.class
    
  end

  ###########
  #  count  #
  ###########
  
  def count
    
    glob_list = Dir.glob( File.join( directory__index, '*' ) )

    return glob_list.count
    
  end

  ############
  #  delete  #
  ############

  def delete

    directories = [ directory__index,
                    directory__reverse_index ]

    # delete index data
    directories.each do |this_directory|

      # delete all indexed contents
      Dir[ File.join( this_directory, '*' ) ].each do |this_file|
        File.delete( this_file )
      end

      # delete index
      Dir.delete( this_directory )

    end

  end

  ############
  #  cursor  #
  ############

  def cursor

    return ::Persistence::Adapter::FlatFile::Cursor.new( @parent_bucket, self )

  end

  #########################
  #  permits_duplicates?  #
  #########################

  def permits_duplicates?
    
    return @permits_duplicates

  end

  ###################
  #  get_object_id  #
  ###################

  def get_object_id( key )

    file__id_for_key = file__index( key )
    
    return open_read_unserialize_and_close( file__id_for_key )

  end

  #####################
  #  index_object_id  #
  #####################
  
  def index_object_id( global_id, value )

    file_path = file__index( value )

    if permits_duplicates?

      if File.exists?( file_path )
        
        open_read_unserialize_perform_action_serialize_write_and_close( file_path ) do |ids|
          ids.push( global_id ).sort.uniq
        end
        
      else

        # index value => ID
        create_or_update_value_serialize_and_write( file_path, [ global_id ] )

      end
            
    else
      
      if File.exists?( file_path )
        
        # check to make sure that we do not already have an index value with a different ID
        open_read_unserialize_perform_action_serialize_write_and_close( file_path ) do |id|

          # If we already have a file for this index value and it holds this object's id,
          # then we don't need to do anything.
          # Otherwise we have a duplicate key in a unique index, which is a problem.
          unless id == global_id
            raise ::Persistence::Exception::DuplicateViolatesUniqueIndex.new( 
                  'Attempt to create entry in index named :' + @name.to_s + 
                  ' would create duplicates in a unique index.' )
          end

        end

      else

        # index value => ID
        create_or_update_value_serialize_and_write( file_path, global_id )

      end
      
    end

    # index ID => value for updating keys if they change
    object_index_location = file__reverse_index_keys_for_global_id( @parent_bucket.name, 
                                                                    @name, 
                                                                    global_id )
    create_or_update_value_serialize_and_write( object_index_location, value )
    
    return self

  end

  ################################
  #  delete_keys_for_object_id!  #
  ################################

  def delete_keys_for_object_id!( global_id )

    key = open_read_unserialize_and_close( file__reverse_index_keys_for_global_id( @parent_bucket.name, @name, global_id ) )

    files = [ file__reverse_index_keys_for_global_id( @parent_bucket.name, @name, global_id ),
              file__index( key ) ]

    files.each do |this_file|
      File.delete( this_file )
    end

    return self

  end

  ######################
  #  directory__index  #
  ######################
  
  def directory__index

    directory__index = File.join( @parent_bucket.parent_adapter.home_directory,
                                  'indexes',
                                  @parent_bucket.name.to_s,
                                  @name.to_s )

    ensure_directory_path_exists( directory__index )

    return directory__index

  end

  ##############################
  #  directory__reverse_index  #
  ##############################
  
  # Bucket Index IDs:        <home_directory>/global_ids/bucket/
  def directory__reverse_index

    directory__reverse_index = File.join( @parent_bucket.parent_adapter.home_directory,
                                          'indexes',
                                          'reverse_index',
                                          @parent_bucket.name.to_s,
                                          @name.to_s )

    ensure_directory_path_exists( directory__reverse_index )

    return directory__reverse_index

  end

  ############################################
  #  file__reverse_index_keys_for_global_id  #
  ############################################

  # Global IDs:              <home_directory>/global_ids/bucket/file__path_encoded_name_from_key.ruby_serialize.txt
  def file__reverse_index_keys_for_global_id( bucket_name, index_name, global_id )

    return File.join( directory__reverse_index,
                      global_id.to_s + adapter_class::SerializationExtension )

  end

  #################
  #  file__index  #
  #################
  
  # Global ID:               <home_directory>/indexes/bucket/file__path_encoded_name_from_key.ruby_serialize.txt
  def file__index( key )

    key = key.to_s if key.is_a?( Class )

    return File.join( directory__index,
                      file__path_encoded_name_from_key( key ) + adapter_class::SerializationExtension )

  end

end
