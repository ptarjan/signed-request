#!/usr/bin/env ruby

require 'base64'
require 'json'
require 'openssl'


def base64_url_decode(str)
  str += '=' * (4 - str.length.modulo(4))
  Base64.decode64(str.gsub('-', '+').gsub('_', '/'))
end

def parse_signed_request(input, secret, max_age=3600)
  encoded_sig, encoded_envelope = input.split('.', 2)
  envelope = JSON.parse(base64_url_decode(encoded_envelope))
  algorithm = envelope['algorithm']

  raise 'Invalid request. (Unsupported algorithm.)' \
    if algorithm != 'HMAC-SHA256'

  raise 'Invalid request. (Too old.)' \
    if envelope['issued_at'] < Time.now.to_i - max_age

  raise 'Invalid request. (Invalid signature.)' \
    if base64_url_decode(encoded_sig) !=
        OpenSSL::HMAC.hexdigest(
          'sha256', secret, encoded_envelope).split.pack('H*')

  return envelope
end

# process from stdin
input = STDIN.read
secret = '13750c9911fec5865d01f3bd00bdf4db'
print parse_signed_request(input, secret).to_json
