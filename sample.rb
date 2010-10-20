#!/usr/bin/env ruby

require 'openssl'
require 'base64'
require 'json'


def base64_url_decode(str)
  str += '=' * (4 - str.length.modulo(4))
  Base64.decode64(str.gsub('-', '+').gsub('_', '/'))
end

def parse_signed_request(input, secret, max_age=3600)
  encoded_sig, encoded_envelope = input.split('.', 2)
  envelope = JSON.parse(base64_url_decode(encoded_envelope))
  algorithm = envelope['algorithm']

  raise 'Invalid request. (Unsupported algorithm.)' \
    if algorithm != 'AES-256-CBC/SHA256' and algorithm != 'HMAC-SHA256'

  raise 'Invalid request. (Too old.)' \
    if envelope['issued_at'] < Time.now.to_i - max_age

  raise 'Invalid request. (Invalid signature.)' \
    if base64_url_decode(encoded_sig) !=
        OpenSSL::HMAC.hexdigest('sha256', secret, encoded_envelope).split.pack('H*')

  # for requests that are signed, but not encrypted, we're done
  return envelope if algorithm == 'HMAC-SHA256'

  # otherwise, decrypt the payload
  cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
  cipher.decrypt
  cipher.key = secret
  cipher.iv = base64_url_decode(envelope['iv'])
  cipher.padding = 0
  decrypted_data = cipher.update(base64_url_decode(envelope['payload']))
  decrypted_data << cipher.final
  return JSON.parse(decrypted_data.strip)
end

# process from stdin
encrypted_payload = STDIN.read
secret = '13750c9911fec5865d01f3bd00bdf4db'
print parse_signed_request(encrypted_payload, secret).to_json
