#!/bin/sh

if [ ! -d .jars ]; then
  mkdir .jars
  cd .jars
  curl http://www.reverse.net/pub/apache//commons/codec/binaries/commons-codec-1.4-bin.tar.gz | tar xz --strip-components=1 commons-codec-1.4/commons-codec-1.4.jar
  curl -O http://json-simple.googlecode.com/files/json_simple-1.1.jar
  cd ..
fi

CP=$PWD/.jars/commons-codec-1.4.jar:$PWD/.jars/json_simple-1.1.jar:$PWD
javac -cp $CP sample.java
java -cp $CP sample
