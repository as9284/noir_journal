import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';
import 'encryption_service.dart';
import '../utils/secure_storage_config.dart';

class SecureStorageService {
  // Use the shared storage configuration to ensure compatibility
  static const FlutterSecureStorage _secureStorage =
      SecureStorageConfig.storage;
  static const String _deviceKeyKey = 'device_encryption_key';
  static const String _entriesKey = 'encrypted_diary_entries';
  static const String _migrationKey = 'encryption_migration_done';
  static Future<String> _getDeviceKey() async {
    String? deviceKey = await _secureStorage.read(key: _deviceKeyKey);

    if (deviceKey == null) {
      deviceKey = EncryptionService.generateExportPassword();
      await _secureStorage.write(key: _deviceKeyKey, value: deviceKey);
    }

    return deviceKey;
  }

  static Future<void> saveEntries(List<DiaryEntry> entries) async {
    try {
      final deviceKey = await _getDeviceKey();
      final entriesJson = entries.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(entriesJson);
      final encryptedData = await EncryptionService.encryptData(
        jsonString,
        deviceKey,
      );
      final encryptedContainer = encryptedData.toJson();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_entriesKey, jsonEncode(encryptedContainer));
    } catch (e) {
      debugPrint('Error saving encrypted entries: $e');
      rethrow;
    }
  }

  static Future<List<DiaryEntry>> loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!await _isMigrationDone()) {
        return await _migrateFromPlaintext();
      }

      final encryptedContainer = prefs.getString(_entriesKey);
      if (encryptedContainer == null) {
        return [];
      }
      final deviceKey = await _getDeviceKey();
      final containerMap =
          jsonDecode(encryptedContainer) as Map<String, dynamic>;
      final encryptedData = EncryptedData.fromJson(containerMap);
      final decryptedJson = await EncryptionService.decryptData(
        encryptedData,
        deviceKey,
      );
      final entriesList = jsonDecode(decryptedJson) as List;

      return entriesList
          .map(
            (entryMap) => DiaryEntry.fromJson(entryMap as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('Error loading encrypted entries: $e');
      return [];
    }
  }

  static Future<List<DiaryEntry>> loadEntriesForExport() async {
    return await loadEntries();
  }

  static Future<void> saveEntriesFromImport(List<DiaryEntry> entries) async {
    await saveEntries(entries);
  }

  static Future<bool> _isMigrationDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_migrationKey) ?? false;
  }

  static Future<List<DiaryEntry>> _migrateFromPlaintext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plaintextEntries = prefs.getStringList('diary_entries') ?? [];

      final entries = <DiaryEntry>[];
      for (final entryString in plaintextEntries) {
        try {
          final decoded = jsonDecode(entryString);
          if (decoded is Map<String, dynamic>) {
            entries.add(DiaryEntry.fromJson(decoded));
          }
        } catch (e) {
          debugPrint('Skipping invalid entry during migration: $e');
        }
      }

      await saveEntries(entries);

      await prefs.remove('diary_entries');
      await prefs.setBool(_migrationKey, true);

      debugPrint(
        'Successfully migrated ${entries.length} entries to encrypted storage',
      );
      return entries;
    } catch (e) {
      debugPrint('Error during migration: $e');
      return [];
    }
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_entriesKey);
    await prefs.remove(_migrationKey);
    await _secureStorage.delete(key: _deviceKeyKey);
  }
}
