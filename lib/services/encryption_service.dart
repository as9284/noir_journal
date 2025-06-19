import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class EncryptionService {
  static const String _salt = 'NoirJournalSalt2025';
  static const String _pepper = 'SecureJournalPepper';
  static String generateExportPassword() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        16,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  static EncryptedData encryptData(String plaintext, String password) {
    try {
      final random = Random.secure();
      final iv = Uint8List.fromList(
        List.generate(16, (_) => random.nextInt(256)),
      );

      final key = _deriveKey(password, _salt);

      final plaintextBytes = utf8.encode(plaintext);
      final encryptedBytes = _xorEncrypt(plaintextBytes, key, iv);
      return EncryptedData(
        data: base64.encode(encryptedBytes),
        iv: base64.encode(iv),
        salt: base64.encode(utf8.encode(_salt)),
        version: '1.0',
      );
    } catch (e) {
      throw EncryptionException('Failed to encrypt data: ${e.toString()}');
    }
  }

  static String decryptData(EncryptedData encryptedData, String password) {
    try {
      final encryptedBytes = base64.decode(encryptedData.data);
      final iv = base64.decode(encryptedData.iv);
      final salt = utf8.decode(base64.decode(encryptedData.salt));

      final key = _deriveKey(password, salt);

      final decryptedBytes = _xorDecrypt(encryptedBytes, key, iv);
      final result = utf8.decode(decryptedBytes);

      return result;
    } catch (e) {
      throw EncryptionException('Failed to decrypt data: ${e.toString()}');
    }
  }

  static Uint8List _deriveKey(String password, String salt) {
    final passwordBytes = utf8.encode(password + _pepper);
    final saltBytes = utf8.encode(salt);

    var key = sha256.convert(passwordBytes + saltBytes).bytes;
    for (int i = 0; i < 1000; i++) {
      key = sha256.convert(key + saltBytes).bytes;
    }

    return Uint8List.fromList(key);
  }

  static Uint8List _xorEncrypt(
    List<int> plaintext,
    Uint8List key,
    Uint8List iv,
  ) {
    final encrypted = Uint8List(plaintext.length);
    final keyLength = key.length;

    for (int i = 0; i < plaintext.length; i++) {
      final keyByte = key[i % keyLength];
      final ivByte = iv[i % iv.length];
      encrypted[i] = plaintext[i] ^ keyByte ^ ivByte ^ (i & 0xFF);
    }

    return encrypted;
  }

  static Uint8List _xorDecrypt(
    List<int> encrypted,
    Uint8List key,
    Uint8List iv,
  ) {
    final decrypted = Uint8List(encrypted.length);
    final keyLength = key.length;

    for (int i = 0; i < encrypted.length; i++) {
      final keyByte = key[i % keyLength];
      final ivByte = iv[i % iv.length];
      decrypted[i] = encrypted[i] ^ keyByte ^ ivByte ^ (i & 0xFF);
    }

    return decrypted;
  }

  static bool isValidPassword(String password) {
    return password.length >= 8 && password.length <= 64;
  }
}

class EncryptedData {
  final String data;
  final String iv;
  final String salt;
  final String version;

  EncryptedData({
    required this.data,
    required this.iv,
    required this.salt,
    required this.version,
  });

  Map<String, dynamic> toJson() => {
    'encrypted_data': data,
    'iv': iv,
    'salt': salt,
    'version': version,
    'encryption_method': 'XOR_PBKDF2',
  };

  factory EncryptedData.fromJson(Map<String, dynamic> json) {
    return EncryptedData(
      data: json['encrypted_data'] as String,
      iv: json['iv'] as String,
      salt: json['salt'] as String,
      version: json['version'] as String,
    );
  }
}

class EncryptionException implements Exception {
  final String message;
  EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}
