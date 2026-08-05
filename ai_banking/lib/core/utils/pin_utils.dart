import 'dart:convert';
import 'package:crypto/crypto.dart';

class PinUtils {
  PinUtils._();

  /// Securely hash a 4-digit or 6-digit PIN using SHA-256
  static String hashPin(String pin) {
    final bytes = utf8.encode('smartbank_salt_$pin');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify if entered PIN matches the stored hash
  static bool verifyPin(String enteredPin, String? storedHash) {
    if (storedHash == null || storedHash.isEmpty) return false;
    final hash = hashPin(enteredPin);
    return hash == storedHash;
  }
}
