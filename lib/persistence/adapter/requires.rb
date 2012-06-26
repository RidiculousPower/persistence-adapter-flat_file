
basepath = 'flat_file'

files = [
 
  'path_helpers',
  'serialization',

  'class_name',

  'bucket/index/index_interface',
  'bucket/index',

  'bucket/bucket_interface',
  'bucket',

  'cursor/cursor_interface',
  'cursor',

  'adapter_interface',

  'marshal',
  'yaml/adapter_interface',
  'yaml'
  
]

files.each do |this_file|
  require_relative( File.join( basepath, this_file ) + '.rb' )
end

require_relative( basepath + '.rb' )
