require 'date'

Gem::Specification.new do |spec|

  spec.name                      =  'rpersistence-adapter-abstract-flat-file'
  spec.rubyforge_project         =  'rpersistence-adapter-abstract-flat-file'
  spec.version                   =  '0.0.1'

  spec.summary                   =  "Rpersistence abstract adapter using flat files storing serialized object data."
  spec.description               =  "Used primarily for writing adapters. Contains generic specs."
  
  spec.authors                   =  [ 'Asher' ]
  spec.email                     =  'asher@ridiculouspower.com'
  spec.homepage                  =  'http://rubygems.org/gems/rpersistence-adapter-abstract'
  
  spec.date                      =  Date.today.to_s
  
  spec.add_dependency               'rpersistence'

  spec.files                     = Dir[ '/{lib,spec}/**/*',
                                        'README*', 
                                        'LICENSE*' ]

end
