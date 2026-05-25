import 'dart:convert';

import 'package:intl/intl.dart';

class Convert {
  /* static final Convert instance = Convert._init();
  // Singleton instance
  Convert._init(); */

  static String toBase64(String value) {
    List<int> textBytes = utf8.encode(value);

    // 2. Encode bytes to Base64 string
    return base64.encode(textBytes);
  }

  static String timeFormat(String value) {
    final now = DateTime.now();

    final hour = int.parse(value.split(':')[0]);
    final minute = int.parse(value.split(':')[1]);
    final second = int.parse(value.split(':')[2]);
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      second,
    );
    return DateFormat('h:mm a').format(dateTime);
  }

  static double shiftDecimal(int number) {
    // Handle 0 or negative numbers if necessary
    if (number <= 0) {
      return 0;
    }

    double decimalValue = number.toDouble();

    // Keep dividing by 10 until the number is less than 1.0
    while (decimalValue >= 1.0) {
      decimalValue /= 10.0;
    }

    return decimalValue;
  }

  static double toDecimalRange(int value, int minInput, int maxInput) {
    // Edge case: Avoid division by zero if min and max are the same
    if (minInput == maxInput) return 1.0;

    // Min-Max normalization formula scaled to a 1-10 range
    double targetMin = 1.0;
    double targetMax = 10.0;

    double scaledValue =
        targetMin +
        ((value - minInput) * (targetMax - targetMin)) / (maxInput - minInput);

    // Clamp the value to ensure it strictly stays between 1 and 10
    return scaledValue.clamp(1.0, 10.0);
  }
}
