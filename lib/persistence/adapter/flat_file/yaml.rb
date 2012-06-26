
# We use the file-system for a storage port in place of a database
#
# Global ID Sequence:      <home_directory>/global_id_sequence.ruby_yaml.txt
# Global IDs:              <home_directory>/global_ids/bucket/key_class/key/global_id.ruby_yaml.txt
# Bucket/key/class:       <home_directory>/bucket_class/id.ruby_yaml.txt
#  Objects:
# Attributes:              <home_directory>/objects/bucket/id#/flat_properties/attribute.ruby_yaml.txt
# Delete Cascades:         <home_directory>/objects/bucket/id#/delete_cascades.ruby_yaml.txt
#
# [  Indexes:                <home_directory>/indexes/index/soft_link_to_key_in_bucket ] - not yet implemented

# FIX - when concerned with multi-threading, Files will need to be locked while attribute modifications occur
#       (or otherwise virtually locked using corresponding lock files).
# FIX - add :lock_non_atomic option and corresponding :release to declare modifications to a non-atomic object complete
# FIX - add transactions

require 'yaml'

class ::Persistence::Adapter::FlatFile::YAML

  include ::Persistence::Adapter::FlatFile::YAML::AdapterInterface
  
  SerializationClass              =  ::YAML
  SerializationMethod             =  :dump
  UnserializationMethod           =  :load
  StringifyClassnames             =  true
  FileContentsAreTextNotBinary    =  true
  SerializationExtension          =  '.yaml'

end
