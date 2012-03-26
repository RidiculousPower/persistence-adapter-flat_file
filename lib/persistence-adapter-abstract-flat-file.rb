
require 'base64'

if $__persistence__spec__development__
  require_relative '../../lib/persistence-adapter-abstract.rb'
else
  require 'persistence-adapter-abstract'
end

module ::Persistence
  module Adapter
    class Abstract
      class FlatFile
        module Interface
        end
        class Bucket
          module Interface
          end
          class Index
            module Interface
            end
          end
        end
        class Cursor
          module Interface
          end
        end        
				module PathHelpers
				end
				module Serialization
				end
				class ClassName < ::String
			  end
      end
    end
  end
end

require_relative 'persistence-adapter-abstract-flat-file/Persistence/Adapter/Abstract/FlatFile/Bucket/Index/Interface.rb'
require_relative 'persistence-adapter-abstract-flat-file/Persistence/Adapter/Abstract/FlatFile/Bucket/Index.rb'

require_relative 'persistence-adapter-abstract-flat-file/Persistence/Adapter/Abstract/FlatFile/Bucket/Interface.rb'
require_relative 'persistence-adapter-abstract-flat-file/Persistence/Adapter/Abstract/FlatFile/Bucket.rb'

require_relative 'persistence-adapter-abstract-flat-file/Persistence/Adapter/Abstract/FlatFile/Cursor/Interface.rb'
require_relative 'persistence-adapter-abstract-flat-file/Persistence/Adapter/Abstract/FlatFile/Cursor.rb'

require_relative 'persistence-adapter-abstract-flat-file/Persistence/Adapter/Abstract/FlatFile/Interface.rb'

require_relative 'persistence-adapter-abstract-flat-file/Persistence/Adapter/Abstract/FlatFile/PathHelpers.rb'
require_relative 'persistence-adapter-abstract-flat-file/Persistence/Adapter/Abstract/FlatFile/Serialization.rb'
require_relative 'persistence-adapter-abstract-flat-file/Persistence/Adapter/Abstract/FlatFile/ClassName.rb'

require_relative 'persistence-adapter-abstract-flat-file/Persistence/Adapter/Abstract/FlatFile.rb'