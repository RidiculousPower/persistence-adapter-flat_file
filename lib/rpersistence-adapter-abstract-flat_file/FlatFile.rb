# Rpersistence::Adapter::FlatFile
#
# Flat-File Adapter Module

#---------------------------------------------------------------------------------------------------------#
#------------------------------------  Flat-File Adapter Module  -----------------------------------------#
#---------------------------------------------------------------------------------------------------------#

module Rpersistence::Adapter::Abstract::FlatFile

  ######################################### Public Interface ################################################
  
  include Rpersistence::Adapter::Abstract::Support::Initialize
  include Rpersistence::Adapter::Abstract::Support::Enable
  include Rpersistence::Adapter::Abstract::Support::PrimaryKey::Simple

  include Rpersistence::Adapter::Abstract::FlatFile::Configuration
  include Rpersistence::Adapter::Abstract::FlatFile::ID
  include Rpersistence::Adapter::Abstract::FlatFile::Objects
  include Rpersistence::Adapter::Abstract::FlatFile::Objects::Properties
  include Rpersistence::Adapter::Abstract::FlatFile::Indexing

  ####################################### Internal Interface ################################################

  include Rpersistence::Adapter::Abstract::FlatFile::Locations
  include Rpersistence::Adapter::Abstract::FlatFile::Serialization

	CursorClass = Rpersistence::Adapter::Abstract::FlatFile::Cursor
	
  def initialize( home_directory = nil )
    super
    # make sure we have a sequence
    create_or_update_value_serialize_and_write( file_location__global_id_sequence, -1 )
  end

end
