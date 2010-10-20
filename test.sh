#!/bin/bash

LANGS=(php rb py java.sh)
SIGNED=`DO_ENCRYPT=0 ./generate.php`
ENCRYPTED=`DO_ENCRYPT=1 ./generate.php`
EXPECTED='the answer is forty two'

for each in "${LANGS[@]}"; do
  echo "$each:"
  echo -n $SIGNED | ./sample.$each | grep "$EXPECTED" > /dev/null \
    && echo " > success for signed" || echo " > failed for signed"
  echo -n $ENCRYPTED | ./sample.$each | grep "$EXPECTED" > /dev/null \
    && echo " > success for encrypted" || echo " > failed for encrypted"
  echo
done
