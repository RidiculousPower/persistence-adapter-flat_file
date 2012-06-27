require 'date'

Gem::Specification.new do |spec|

  spec.name                      =  'persistence-adapter-flat_file'
  spec.rubyforge_project         =  'persistence-adapter-flat_file'
  spec.version                   =  '0.0.2'

  spec.summary                   =  "Adapter to use flat files as storage port for Persistence."
  spec.description               =  "Implements necessary methods to run Persistence on top of the file system without a database."
  
  spec.authors                   =  [ 'Asher' ]
  spec.email                     =  'asher@ridiculouspower.com'
  spec.homepage                  =  'http://rubygems.org/gems/persistence-adapter-flat_file'
  
  spec.add_dependency            'persistence'
  
  spec.date                      = Date.today.to_s
  
  spec.files                     = Dir[ '{lib,spec}/**/*',
                                        'README*', 
                                        'LICENSE*',
                                        'CHANGELOG*' ]

end
