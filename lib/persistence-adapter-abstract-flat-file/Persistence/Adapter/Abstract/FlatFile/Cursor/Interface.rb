# ::Persistence::Adapter::FlatFile::Cursor
#
# Cursor for Flat-File Adapter Module

#---------------------------------------------------------------------------------------------------------#
#----------------------------------  Flat-File Cursor Adapter Module  ------------------------------------#
#---------------------------------------------------------------------------------------------------------#

module ::Persistence::Adapter::Abstract::FlatFile::Cursor::Interface

  include ::Persistence::Adapter::Abstract::FlatFile::PathHelpers
  include ::Persistence::Adapter::Abstract::FlatFile::Serialization

	################
	#  initialize  #
	################

	def initialize( parent_bucket_instance, parent_index_instance )

    @parent_bucket = parent_bucket_instance
    @parent_index = parent_index_instance

		# we're iterating a directory of files named after their key_digest and containing their global ID
		@key_to_id_directory = ( @parent_index ? @parent_index.instance_eval { directory__index }
		                                       : @parent_bucket.instance_eval { directory__ids_in_bucket } )
		
		# instantiate enumerator to track our current position
		init_current_position
		
	end
	
	###########
	#  close  #
	###########
	
	def close
	  
	  # nothing required

  end
  
	###################
  #  adapter_class  #
  ###################
  
  def adapter_class
    
    return @parent_bucket.parent_adapter.class
    
  end
  
	################
	#  persisted?  #
	################

  # persisted? is responsible for setting the cursor position
	def persisted?( *args )

		has_key = false
		no_key  = false
		case args.count
		when 1
			key = args[0]
		when 0
			no_key = true
		end
    
		# if we have no args we are asking whether any keys exist
		if no_key

      init_current_position

			has_key = true unless Dir[ @key_to_id_directory ].empty?
			
		else

			# check if we have a position that currently points to key - if so we are done
	    if has_key = ( current_key == key )
			  return has_key
			end

      init_current_position

			# Find location of key in Directory enumerator.
			# It seems we can't use Dir#seek because there is no direct way to find the index from a file path.
			# Please prove me wrong if you can!
			begin

			  until has_key = ( current_key == key )
			    self.next
		    end
			rescue StopIteration
			end

		end
		
		return has_key

	end

	###########
	#  first  #
	###########
	
	# first should set the cursor position and return the first ID or object hash
	def first
		@current_position.rewind
		return self.next
	end

	#############
	#  current  #
	#############
	
	# current should return the current ID or object hash
	def current

		current = nil

		if @current_position
			current = open_read_unserialize_and_close( File.join( @key_to_id_directory, 
			                                                      @current_position.peek ) )
		end

		return current

	end

	#################
	#  current_key  #
	#################
	
	# current should return the current ID or object hash
	def current_key

    current_key = nil
    
    if @parent_index
      encoded_key_as_file_name = @current_position.peek
      encoded_key = encoded_key_as_file_name.split( '.' )[ 0 ]
      current_key = file__key_from_path_encoded_name( encoded_key )
    else
      current_key = current
    end

    return current_key
    
  end
  
	##########
	#  next  #
	##########
	
	def next

	  @current_position.next

		return current

	end

  ##################################################################################################
      private ######################################################################################
  ##################################################################################################

	###########################
	#  init_current_position  #
	###########################

	def init_current_position( directory = nil )
    
    if directory
      @key_to_id_directory = directory
    end
    
		if @current_position

			@current_position.rewind

		else

			current_position_entries = Dir.new( @key_to_id_directory ).entries
			current_position_entries.delete( '.' )
			current_position_entries.delete( '..' )
			@current_position = current_position_entries.each

		end

	end

end
