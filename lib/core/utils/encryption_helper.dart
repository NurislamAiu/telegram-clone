import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EncryptionService {
  final Key key;
  final IV iv;

  EncryptionService()
      : key = Key.fromUtf8(dotenv.env['AES_SECRET']!.padRight(32, '0')),
        iv = IV.fromLength(16);

  String encrypt(String plainText) {
    final iv = IV.fromSecureRandom(16); // ✅ Генерируем уникальный IV
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Возвращаем IV и зашифрованный текст вместе, через ::
    return '${iv.base64}::${encrypted.base64}';
  }

  String decrypt(String combined) {
    try {
      final parts = combined.split('::');
      if (parts.length != 2) throw Exception("Invalid encrypted format");

      final iv = IV.fromBase64(parts[0]);
      final encryptedText = parts[1];
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      return encrypter.decrypt64(encryptedText, iv: iv);
    } catch (e) {
      print('❌ Decryption error: $e');
      return '❌ decryption failed';
    }
  }
}