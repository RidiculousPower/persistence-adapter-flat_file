# Rpersistence::Adapter::FlatFile::Cursor
#
# Cursor for Flat-File Adapter Module

#---------------------------------------------------------------------------------------------------------#
#----------------------------------  Flat-File Cursor Adapter Module  ------------------------------------#
#---------------------------------------------------------------------------------------------------------#

class Rpersistence::Adapter::Abstract::FlatFile::Cursor

	include Rpersistence::Cursor::ParseInitializationArgs

	################
	#  initialize  #
	################

	def initialize( *args )

		@persistence_port, 
		@persistence_bucket, 
		@index, 
		@index_value = parse_cursor_initialization_args( args )

		# we're iterating a directory of files named after their key_digest and containing their global ID
		@key_to_id_directory = ( @index ? @persistence_port.adapter.instance_eval { directory_location__index( @persistence_bucket, @index ) }
		                                : @persistence_port.adapter.instance_eval { directory_location__ids_in_bucket( @persistence_bucket ) } )
		
		# instantiate enumerator to track our current position
		init_current_position( @key_to_id_directory )
		
	end
	
	####################
	#  home_directory  #
	####################

	def home_directory
		return persistence_port.adapter.home_directory
	end
	
	##############
	#  has_key?  #
	##############

  # has_key? is responsible for setting the cursor position
	def has_key?( *args )

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

			has_key = true unless Dir[ @key_to_id_directory ].empty?
			
		else

			# check if we have a position that currently points to key - if so we are done
			return if has_key = ( @current_position.peek == key )

			# We test quickly to tell whether a key exists without having to iterate.
			# Then we still have to get the current position by iterating.
			# If we know the key doesn't exist, return without iterating the set.
			return unless has_key = ( @index ? File.exists?( @persistence_port.adapter.instance_eval { file_location__index( @persistence_bucket, @index, key ) } )
                      			           : File.exists?( @persistence_port.adapter.instance_eval { file_location__global_id_for_bucket_key( @persistence_bucket, key ) } ) )
			
			# Find location of key in Directory enumerator.
			# It seems we can't use Dir#seek because there is no direct way to find the index from a file path.
			# Please prove me wrong if you can!
			@current_position.rewind ; begin ; until @current_position.next == key ; end ; rescue StopIteration ; end

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
			puts 'here: ' + @current_position.to_s
			puts 'peek: ' + @current_position.peek
			current = @persistence_port.adapter.instance_eval { open_read_unserialize_and_close( @current_position.peek ) }
		end
		return current
	end

	##########
	#  next  #
	##########
	
	def next
	  @current_position.next
		return current
	end

end
