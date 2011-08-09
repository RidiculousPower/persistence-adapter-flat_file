# Rpersistence::Adapter::FlatFile::Cursor
#
# Cursor for Flat-File Adapter Module

#---------------------------------------------------------------------------------------------------------#
#----------------------------------  Flat-File Cursor Adapter Module  ------------------------------------#
#---------------------------------------------------------------------------------------------------------#

class Rpersistence::Adapter::Abstract::FlatFile::Cursor

  ###########################################################################################################
      private ###############################################################################################
  ###########################################################################################################

	###########################
	#  init_current_position  #
	###########################

	def init_current_position( directory )
		if @current_position
			@current_position.rewind
		else
			current_position_entries = Dir.new( directory ).entries
			current_position_entries.delete( '.' )
			current_position_entries.delete( '..' )
			@current_position = current_position_entries.each
		end
	end

	####################
	#  home_directory  #
	####################

	def home_directory
    return persistence_port.adapter.home_directory
  end
  
end
