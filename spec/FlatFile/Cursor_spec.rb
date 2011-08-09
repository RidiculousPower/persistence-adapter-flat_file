# Rpersistence::Adapter::FlatFile::Cursor
#
# Cursor for Flat-File Adapter Module

#---------------------------------------------------------------------------------------------------------#
#----------------------------------  Flat-File Cursor Adapter Module  ------------------------------------#
#---------------------------------------------------------------------------------------------------------#
$__rpersistence__spec__development = true

require_relative '../../../../../lib/rpersistence-adapter-abstract.rb'

describe Rpersistence::Adapter::Abstract::FlatFile::Cursor do

	##############
	#  has_key?  #
	##############

	it 'it can report if it has a key' do
	  Rpersistence.enable_port( :adapter, Rpersistence::Adapter::Abstract::FlatFile::MockAdapter.new )
	  class Rpersistence::Adapter::Abstract::FlatFile::Cursor::MockObject
      attr_accessor :some_value, :some_other_value
	    attr_index    :some_value, :some_other_value
    end
    instance = Rpersistence::Adapter::Abstract::FlatFile::Cursor::MockObject.new
    instance.some_value = 12
    instance.some_other_value = 37
    instance.persist!
    instance.persistence_id.should == 0
	  # cursor on primary bucket
	  cursor = Rpersistence::Adapter::Abstract::FlatFile::Cursor.new( :adapter, instance.persistence_bucket )
    cursor.has_key?( 0 ).should == true
    # cursor on index
	  cursor = Rpersistence::Adapter::Abstract::FlatFile::Cursor.new( :adapter, instance.persistence_bucket, :some_value )
    cursor.has_key?( 12 ).should == true
	  cursor = Rpersistence::Adapter::Abstract::FlatFile::Cursor.new( :adapter, instance.persistence_bucket, :some_value => 12 )
    cursor.has_key?( 12 ).should == true
    cursor.has_key?( 37 ).should == false
	  cursor = Rpersistence::Adapter::Abstract::FlatFile::Cursor.new( :adapter, instance.persistence_bucket, :some_other_value )
    cursor.has_key?( 12 ).should == true
	  cursor = Rpersistence::Adapter::Abstract::FlatFile::Cursor.new( :adapter, instance.persistence_bucket, :some_other_value => 37 )
    cursor.has_key?( 37 ).should == true
    cursor.has_key?( 12 ).should == false
  end

	###########
	#  first  #
	###########
	
	it 'can return its first key' do
	  cursor = Rpersistence::Cursor::Mock.new( :adapter, 'bucket' )

  end

	#############
	#  current  #
	#############
	
	it 'can return the current key' do
	  cursor = Rpersistence::Cursor::Mock.new( :adapter, 'bucket' )

  end

	##########
	#  next  #
	##########
	
	it 'can return the next key' do
	  cursor = Rpersistence::Cursor::Mock.new( :adapter, 'bucket' )

  end

end
