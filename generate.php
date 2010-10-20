#!/usr/bin/env php
<?php

function base64_url_encode($input) {
  $str = strtr(base64_encode($input), '+/=', '-_.');
  $str = str_replace('.', '', $str); // remove padding
  return $str;
}

function generate_signed_request($data, $secret, $encrypt=false) {
  // wrap data inside payload if we are encrypting
  if ($encrypt) {
    $cipher = MCRYPT_RIJNDAEL_128;
    $mode = MCRYPT_MODE_CBC;

    $iv = mcrypt_create_iv(
      mcrypt_get_iv_size($cipher, $mode), MCRYPT_DEV_URANDOM);
    $data = array(
      'payload' => base64_url_encode(mcrypt_encrypt(
        $cipher, $secret, json_encode($data), $mode, $iv)),
      'iv' => base64_url_encode($iv),
    );
  }

  // always present, and always at the top level
  $data['algorithm'] = $encrypt ? 'AES-256-CBC/SHA256' : 'HMAC-SHA256';
  $data['issued_at'] = time();

  // sign it
  $payload = base64_url_encode(json_encode($data));
  $sig = base64_url_encode(
    hash_hmac('sha256', $payload, $secret, $raw=true));
  return $sig.'.'.$payload;
}

$secret = '13750c9911fec5865d01f3bd00bdf4db';
echo generate_signed_request(
  array('the' => array('answer' => "the answer is forty two")),
  $secret,
  $_SERVER['DO_ENCRYPT'] == '1');
