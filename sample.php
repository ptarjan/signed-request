#!/usr/bin/env php
<?php

function base64_url_decode($input) {
  return base64_decode(strtr($input, '-_', '+/'));
}

function parse_signed_request($input, $secret, $max_age=3600) {
  list($encoded_sig, $encoded_envelope) = explode('.', $input, 2);
  $envelope = json_decode(base64_url_decode($encoded_envelope), true);
  $algorithm = $envelope['algorithm'];

  if ($algorithm != 'AES-256-CBC/SHA256' && $algorithm != 'HMAC-SHA256') {
    throw new Exception('Invalid request. (Unsupported algorithm.)');
  }

  if ($envelope['issued_at'] < time() - $max_age) {
    throw new Exception('Invalid request. (Too old.)');
  }

  if (base64_url_decode($encoded_sig) !=
        hash_hmac('sha256', $encoded_envelope, $secret, $raw=true)) {
    throw new Exception('Invalid request. (Invalid signature.)');
  }

  // for requests that are signed, but not encrypted, we're done
  if ($algorithm == 'HMAC-SHA256') {
    return $envelope;
  }

  // otherwise, decrypt the payload
  return json_decode(trim(mcrypt_decrypt(
    MCRYPT_RIJNDAEL_128,
    $secret,
    base64_url_decode($envelope['payload']),
    MCRYPT_MODE_CBC,
    base64_url_decode($envelope['iv']))), true);
}

// process from stdin
$input = fgets(fopen('php://stdin', 'r'));
$secret = '13750c9911fec5865d01f3bd00bdf4db';
try {
  echo json_encode(parse_signed_request($input, $secret));
} catch(Exception $e) {
  fwrite(fopen('php://stderr', 'w'), $e);
}
