signed & encrypted requests
===========================

Provides samples for decoding signed and encrypted requests in a few different
languages. To run the tests:

    ./test.sh

Note, you'll likely need to ensure some extensions are available in your
environment.


Python
------

Requires [PyCrypto](http://www.dlitz.net/software/pycrypto/). To install, run:

     easy_install pycrypto

Ruby
----

Ruby requires [JSON](http://flori.github.com/json). To install, run

     gem install json

Java
----

Java requires these libraries:

* [Apache Commons Codec](http://commons.apache.org/codec/)
* [json-simple](http://code.google.com/p/json-simple/)

PHP
---

You'll need these extensions:

* [JSON](http://php.net/json)
* [Hash](http://php.net/hash)
* [mcrypt](http://php.net/mcrypt)

If these aren't installed, then your script will fail with a message like:

     Fatal error: Call to undefined function mcrypt_create_iv()

If they aren't activated but are present on your system, you can try to
activate them by adding these lines to your php.ini file:

    extension=mcrypt.so

If that doesn't work (gives as "Unable to load dynamic library" error), then
you'll need to recompile PHP with the extensions included or install the
extension using your system package manager.
