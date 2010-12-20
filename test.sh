#!/bin/bash

LANGS=(php rb py java.sh)
GENERATE=`./generate.php`
EXPECTED='the answer is forty two'

for each in "${LANGS[@]}"; do
  echo "$each:"
  echo -n $GENERATE | ./sample.$each | grep "$EXPECTED" > /dev/null \
    && echo " > success" || echo " > failed"
  echo
done
