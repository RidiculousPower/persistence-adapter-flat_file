# Flat File Persistence Adapter #

http://rubygems.org/gems/persistence-adapter-flat_file

# Summary #

Adapter to use flat files as storage port for <a href="https://rubygems.org/gems/persistence">Persistence (Gem)</a> (<a href="https://github.com/RidiculousPower/persistence">Persistence on GitHub</a>).

# Description #

Implements necessary methods to run Persistence on top of the file system without a database.

# Install #

* sudo gem install persistence-adapter-flat_file

# Usage #

The FlatFile adapter is an abstract implementation. Using it requires specifying serialization methods. This permits the creation of concrete adapter implementations that are highly configurable.

At this point, two versions exist:

* FlatFile::Marshal
* FlatFile::YAML

To use Marshal:

```ruby
flat_file_adapter = ::Persistence::Adapter::FlatFile::Marshal.new

Persistence.enable_port( :flat_file_marshal_port, flat_file_adapter )
```

To use YAML:

```ruby
flat_file_adapter = ::Persistence::Adapter::FlatFile::YAML.new

Persistence.enable_port( :flat_file_yaml_port, flat_file_adapter )
```

# License #

  (The MIT License)

  Copyright (c) 2012, Asher, Ridiculous Power

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  'Software'), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
