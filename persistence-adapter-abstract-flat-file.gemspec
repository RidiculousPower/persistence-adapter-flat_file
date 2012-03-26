require 'date'

Gem::Specification.new do |spec|

  spec.name                      =  'persistence-adapter-abstract-flat-file'
  spec.rubyforge_project         =  'persistence-adapter-abstract-flat-file'
  spec.version                   =  '0.0.1'

  spec.summary                   =  "Persistence abstract adapter using flat files storing serialized object data."
  spec.description               =  "Used primarily for writing adapters. Contains generic specs."
  
  spec.authors                   =  [ 'Asher' ]
  spec.email                     =  'asher@ridiculouspower.com'
  spec.homepage                  =  'http://rubygems.org/gems/persistence-adapter-abstract'
  
  spec.date                      =  Date.today.to_s
  
  spec.add_dependency               'persistence'

  spec.files                     = Dir[ 'lib/**/*',
                                        'spec/**/*',
                                        'README*', 
                                        'LICENSE*' ]

end
