# Rpersistence::Adapter::FlatFile::MockAdapter
#
# Mock Adapter for Testing Flat-File Adapter Modules

#---------------------------------------------------------------------------------------------------------#
#-----------------------------------  Flat-File Mock Adapter Module  -------------------------------------#
#---------------------------------------------------------------------------------------------------------#

class Rpersistence::Adapter::Abstract::FlatFile::MockAdapter

  include Rpersistence::Adapter::Abstract::FlatFile

  SerializationClass              =  Marshal
  SerializationMethod             =  :dump
  UnserializationMethod           =  :load
  StringifyClassnames             =  false
  FileContentsAreTextNotBinary    =  false

  ################
  #  initialize  #
  ################

  def initialize
    @home_directory = '/tmp/rpersistence-adapter-flat-file-mock'
  end

end
