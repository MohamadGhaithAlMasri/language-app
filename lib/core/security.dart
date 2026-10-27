import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

class SecurityUtils {
  static const String _seed = 'MOI_Language_Exam_Secure_Key_26!';

  static enc.Key get _key {
    final keyBytes = sha256.convert(utf8.encode(_seed)).bytes;
    return enc.Key(Uint8List.fromList(keyBytes));
  }

  static String encrypt(String plainText) {
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final combined = "${iv.base64}:${encrypted.base64}";
    return base64.encode(utf8.encode(combined));
  }

  static String decrypt(String base64Encrypted) {
    final combined = utf8.decode(base64.decode(base64Encrypted));
    final parts = combined.split(":");
    if (parts.length != 2) {
      throw const FormatException("Invalid encrypted payload format");
    }
    final iv = enc.IV.fromBase64(parts[0]);
    final ciphertext = parts[1];
    final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
    return encrypter.decrypt64(ciphertext, iv: iv);
  }
}
