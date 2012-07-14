
module ::Persistence::Adapter::FlatFile::YAML::AdapterInterface

  include ::Persistence::Adapter::FlatFile::AdapterInterface
  
  #############################
  #  get_class_for_object_id  #
  #############################

  def get_class_for_object_id( global_id )
    
    if klass_string = open_read_unserialize_and_close( file__class_for_id( global_id ) )

      # for YAML - can't store anonymous Class, but sometimes we need to store "Class", so we store all class as string and get back
      klass = klass_string.split( '::' ).inject( Object ) { |namespace, next_part| namespace.const_get( next_part ) }
      
    end
    
    return klass

  end
  
end