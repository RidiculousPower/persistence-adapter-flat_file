# Rpersistence::Adapter::FlatFile::Objects::Properties
#
# Configuration for Flat-File Adapter Module

#---------------------------------------------------------------------------------------------------------#
#-------------------------------  Flat-File Configuration Adapter Module  --------------------------------#
#---------------------------------------------------------------------------------------------------------#

module Rpersistence::Adapter::Abstract::FlatFile::Configuration

	######################
	#  delete_cascades?  #
	######################

	def delete_cascades?( object, property_name )
	  return open_read_unserialize_and_close( file_location__delete_cascades( object.persistence_bucket, object.persistence_id, property_name ) )
	end

end

