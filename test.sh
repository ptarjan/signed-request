#!/bin/bash

LANGS=(php rb py)
ENCRYPTED=`./generate.php`
EXPECTED='the answer is forty two'

for each in "${LANGS[@]}"; do
  echo -n "$each: "
  echo -n $ENCRYPTED | ./sample.$each | grep "$EXPECTED" > /dev/null \
    && echo "success" || echo "failed"
done
