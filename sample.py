#!/usr/bin/env python

import base64
import hashlib
import hmac
import json
import sys
import time


def base64_url_decode(input):
    input = input.encode(u'ascii')
    input += '=' * (4 - (len(input) % 4))
    return base64.urlsafe_b64decode(input)

def parse_signed_request(input, secret, max_age=3600):
    encoded_sig, encoded_envelope = input.split('.', 1)
    envelope = json.loads(base64_url_decode(encoded_envelope))
    algorithm = envelope['algorithm']

    if algorithm != 'HMAC-SHA256':
        raise Exception('Invalid request. (Unsupported algorithm.)')

    if envelope['issued_at'] < time.time() - max_age:
        raise Exception('Invalid request. (Too old.)')

    if base64_url_decode(encoded_sig) != hmac.new(
            secret, msg=encoded_envelope, digestmod=hashlib.sha256).digest():
        raise Exception('Invalid request. (Invalid signature.)')

    return envelope

# process from stdin
input = sys.stdin.read()
secret = '13750c9911fec5865d01f3bd00bdf4db'
print json.dumps(parse_signed_request(input, secret)),
