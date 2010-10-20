import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.Map;

import javax.crypto.Cipher;
import javax.crypto.Mac;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.codec.binary.Base64;
import org.json.simple.parser.JSONParser;

class sample {

  public static byte[] base64_url_decode(String input) throws IOException {
    return new Base64(true).decode(input);
  }

  public static Map parse_signed_request(String input, String secret) throws Exception {
    return parse_signed_request(input, secret, 3600);
  }

  public static Map parse_signed_request(String input, String secret, int max_age) throws Exception {
    String[] split = input.split("[.]", 2);

    String encoded_sig = split[0];
    String encoded_envelope = split[1];
    JSONParser parser = new JSONParser();
    Map envelope = (Map) parser.parse(new String(base64_url_decode(encoded_envelope)));

    String algorithm = (String) envelope.get("algorithm");

    if (!algorithm.equals("AES-128-CBC/SHA256") && !algorithm.equals("HMAC-SHA256")) {
      throw new Exception("Invalid request. (Unsupported algorithm.)");
    }

    if (((Long) envelope.get("issued_at")) < System.currentTimeMillis() / 1000 - max_age) {
      throw new Exception("Invalid request. (Too old.)");
    }

    byte[] key = secret.getBytes();
    SecretKey hmacKey = new SecretKeySpec(key, "HMACSHA256");
    Mac mac = Mac.getInstance("HMACSHA256");
    mac.init(hmacKey);
    byte[] digest = mac.doFinal(encoded_envelope.getBytes());

    if (!Arrays.equals(base64_url_decode(encoded_sig), digest)) {
      throw new Exception("Invalid request. (Invalid signature.)");
    }

    // for requests that are signed, but not encrypted, we"re done
    if (algorithm.equals("HMAC-SHA256")) {
      return envelope;
    }

    // otherwise, decrypt the payload
    byte[] iv = base64_url_decode((String) envelope.get("iv"));
    IvParameterSpec ips = new IvParameterSpec(iv);

    SecretKey aesKey = new SecretKeySpec(key, "AES");
    Cipher cipher = Cipher.getInstance("AES/CBC/NoPadding");
    cipher.init(Cipher.DECRYPT_MODE, aesKey, ips);

    byte[] raw_ciphertext = base64_url_decode((String) envelope.get("payload"));
    byte[] plaintext = cipher.doFinal(raw_ciphertext);
    return (Map) parser.parse(new String(plaintext).trim());
  }

  public static void main(String[] args) throws Exception {
    BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
    String input = in.readLine();
    String secret = "13750c9911fec5865d01f3bd00bdf4db";
    System.out.println(parse_signed_request(input, secret));
  }

}
