# Rpersistence::Adapter::FlatFile::Indexing
#
# Indexing for Flat-File Adapter Module

#---------------------------------------------------------------------------------------------------------#
#--------------------------------  Flat-File Indexing Adapter Module  ------------------------------------#
#---------------------------------------------------------------------------------------------------------#

require_relative '../../../../../lib/rpersistence-adapter-abstract.rb'

describe Rpersistence::Adapter::Abstract::FlatFile::Indexing do

  class MockObject
    # mock
    attr_accessor :indexed_attribute, :indexed_attribute_with_duplicates
  end

  ##################
  #  create_index  #
  ##################
  
  it 'can create an index for an attribute, which can be unique or permit duplicates' do
    Rpersistence::Adapter::Abstract::FlatFile::MockAdapter.new.instance_eval do
      # we create indexes on an instance here only because we need the same persistence bucket
      # when we are indexing an object attribute
      create_index( MockObject, :indexed_attribute, false )
      create_index( MockObject, :indexed_attribute_with_duplicates, true )
      File.exists?( directory_location__index( MockObject.instance_persistence_bucket, :indexed_attribute ) ).should == true
      File.exists?( directory_location__index( MockObject.instance_persistence_bucket, :indexed_attribute_with_duplicates ) ).should == true
    end
  end

  ################
  #  has_index?  #
  ################

  it 'can report whether an index exists on attribute' do
    Rpersistence::Adapter::Abstract::FlatFile::MockAdapter.new.instance_eval do
      has_index?( MockObject, :indexed_attribute ).should == true
      has_index?( MockObject, :indexed_attribute_with_duplicates ).should == true
    end
  end

  ###############################
  #  index_permits_duplicates?  #
  ###############################

  it 'can report whether an index permits duplicates' do
    Rpersistence::Adapter::Abstract::FlatFile::MockAdapter.new.instance_eval do
      index_permits_duplicates?( MockObject, :indexed_attribute ).should == false
      index_permits_duplicates?( MockObject, :indexed_attribute_with_duplicates ).should == true
    end
  end
  
  ############################
  #  index_property_for_object  #
  ############################
  
  it 'can index the value for an attribute on an object with an index on attribute' do
    rspec = self
    Rpersistence::Adapter::Abstract::FlatFile::MockAdapter.new.instance_eval do
      # unique
      object = MockObject.new
      object.indexed_attribute = 'some value'
      object.indexed_attribute_with_duplicates = 1
      object.persistence_id = 42
      index_property_for_object( object, :indexed_attribute, object.indexed_attribute )
      File.exists?( file_location__index( object.persistence_bucket, 
                                          :indexed_attribute, 
                                          object.indexed_attribute ) ).should == true
      index_property_for_object( object, :indexed_attribute_with_duplicates, object.indexed_attribute_with_duplicates )
      File.exists?( file_location__index( object.persistence_bucket, 
                                          :indexed_attribute_with_duplicates, 
                                          object.indexed_attribute_with_duplicates ) ).should == true
      # duplicates
      other_object = MockObject.new
      other_object.persistence_id = 37
      other_object.indexed_attribute = object.indexed_attribute  # this should fail - unique index
      other_object.indexed_attribute_with_duplicates = 1
      lambda do
        index_property_for_object( other_object, :indexed_attribute, other_object.indexed_attribute )
      end.should rspec.raise_error( Rpersistence::Exceptions::DuplicateViolatesUniqueIndexError )
      index_property_for_object( other_object, :indexed_attribute_with_duplicates, other_object.indexed_attribute_with_duplicates )
      duplicate_id_location = file_location__index( other_object.persistence_bucket, 
                                                    :indexed_attribute_with_duplicates, 
                                                    object.indexed_attribute_with_duplicates )
      File.exists?( duplicate_id_location ).should == true
      open_read_unserialize_and_close( duplicate_id_location ).should == [ 37, 42 ]
    end
  end

  ##################
  #  delete_index  #
  ##################
  
  it 'can delete an index' do
    Rpersistence::Adapter::Abstract::FlatFile::MockAdapter.new.instance_eval do
      delete_index( MockObject, :indexed_attribute )
      has_index?( MockObject, :indexed_attribute ).should == false
    end
  end

  #############################
  #  delete_index_for_object  #
  #############################
  
  it 'can delete an index for an object' do
    Rpersistence::Adapter::Abstract::FlatFile::MockAdapter.new.instance_eval do
      object = MockObject.new
      object.persistence_id = 42
      File.exists?( file_location__index( object.persistence_bucket, :indexed_attribute_with_duplicates, 1 ) ).should == true
      delete_index_for_object( object.persistence_bucket, :indexed_attribute_with_duplicates, object.persistence_id )
      File.exists?( file_location__index( object.persistence_bucket, :indexed_attribute_with_duplicates, 1 ) ).should == false
    end
  end

end
