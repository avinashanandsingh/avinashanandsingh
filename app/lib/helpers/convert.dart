import 'dart:convert';

class Convert {
  /* static final Convert instance = Convert._init();
  // Singleton instance
  Convert._init(); */

  static String toBase64(String value) {
    List<int> textBytes = utf8.encode(value);

    // 2. Encode bytes to Base64 string
    return base64.encode(textBytes);
  }
}
