import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/secure_storage_config.dart';

class EncryptionService {
  static const String _saltKey = 'encryption_user_salt';
  static const String _pepperKey = 'encryption_secure_pepper';
  static const FlutterSecureStorage _storage = SecureStorageConfig.storage;
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

  static Future<EncryptedData> encryptData(
    String plaintext,
    String password,
  ) async {
    try {
      final random = Random.secure();
      final iv = Uint8List.fromList(
        List.generate(16, (_) => random.nextInt(256)),
      );
      final salt = await _getUserSalt();
      final key = await _deriveKey(password, salt);

      final plaintextBytes = utf8.encode(plaintext);
      final encryptedBytes = _xorEncrypt(plaintextBytes, key, iv);
      return EncryptedData(
        data: base64.encode(encryptedBytes),
        iv: base64.encode(iv),
        salt: salt, // Store the salt directly (it's already base64 encoded)
        version: '2.0', // Increment version for new encryption method
      );
    } catch (e) {
      throw EncryptionException('Failed to encrypt data: ${e.toString()}');
    }
  }

  static Future<String> decryptData(
    EncryptedData encryptedData,
    String password,
  ) async {
    try {
      final encryptedBytes = base64.decode(encryptedData.data);
      final iv = base64.decode(encryptedData.iv);

      // Handle different versions of encryption
      String salt;
      String version = encryptedData.version;

      if (version == '2.0') {
        // Version 2.0 uses secure salt storage - salt is already base64 encoded
        salt = encryptedData.salt;
      } else {
        // Version 1.0 compatibility - salt was UTF-8 encoded then base64 encoded
        salt = utf8.decode(base64.decode(encryptedData.salt));
      }

      final key = await _deriveKey(password, salt, version: version);

      final decryptedBytes = _xorDecrypt(encryptedBytes, key, iv);
      final result = utf8.decode(decryptedBytes);

      return result;
    } catch (e) {
      throw EncryptionException('Failed to decrypt data: ${e.toString()}');
    }
  }

  static Future<Uint8List> _deriveKey(
    String password,
    String salt, {
    String? version,
  }) async {
    String pepper;
    Uint8List saltBytes;
    int iterations;

    if (version == '1.0') {
      // Use old hardcoded pepper for backward compatibility
      pepper = 'SecureJournalPepper';
      saltBytes = utf8.encode(salt);
      iterations = 1000;
    } else {
      // Use secure pepper from keystore for new encryption
      pepper = await _getSecurePepper();
      saltBytes = base64.decode(salt);
      iterations = 10000;
    }

    final passwordBytes = utf8.encode(password + pepper);

    var key = sha256.convert(passwordBytes + saltBytes).bytes;
    for (int i = 0; i < iterations; i++) {
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

  /// Get or generate a unique salt for this user
  static Future<String> _getUserSalt() async {
    String? salt = await _storage.read(key: _saltKey);
    if (salt == null) {
      // Generate a new random salt for this user
      final random = Random.secure();
      final saltBytes = List.generate(32, (_) => random.nextInt(256));
      salt = base64.encode(saltBytes);
      await _storage.write(key: _saltKey, value: salt);
    }
    return salt;
  }

  /// Get or generate a secure pepper stored in keystore
  static Future<String> _getSecurePepper() async {
    String? pepper = await _storage.read(key: _pepperKey);
    if (pepper == null) {
      // Generate a new secure pepper
      final random = Random.secure();
      const chars =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()_+-=[]{}|;:,.<>?';
      pepper = String.fromCharCodes(
        Iterable.generate(
          64,
          (_) => chars.codeUnitAt(random.nextInt(chars.length)),
        ),
      );
      await _storage.write(key: _pepperKey, value: pepper);
    }
    return pepper;
  }

  /// Migrate existing encrypted data to the new secure format
  /// This should be called once when the app updates to the new encryption system
  static Future<void> migrateToSecureEncryption() async {
    try {
      // Check if we already have secure credentials
      final existingSalt = await _storage.read(key: _saltKey);
      final existingPepper = await _storage.read(key: _pepperKey);

      if (existingSalt != null && existingPepper != null) {
        // Already migrated
        return;
      }

      // Initialize secure salt and pepper for new installations
      await _getUserSalt(); // This will create a new salt if none exists
      await _getSecurePepper(); // This will create a new pepper if none exists

      debugPrint(
        'Encryption migration completed - secure salt and pepper initialized',
      );
    } catch (e) {
      debugPrint('Encryption migration failed: $e');
      // Don't throw here - let the app continue with whatever encryption it can use
    }
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
