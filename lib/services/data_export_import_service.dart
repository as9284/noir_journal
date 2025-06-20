import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/diary_entry.dart';
import '../services/encryption_service.dart';
import '../services/secure_storage_service.dart';

class DataExportImportService {
  static Future<List<DiaryEntry>> _loadAllEntries() async {
    return await SecureStorageService.loadEntriesForExport();
  }

  static Future<void> _saveAllEntries(List<DiaryEntry> entries) async {
    await SecureStorageService.saveEntriesFromImport(entries);
  }

  static Future<ExportResult> exportData() async {
    try {
      final entries = await _loadAllEntries();

      if (entries.isEmpty) {
        return ExportResult(
          success: false,
          message: 'No journal entries found to export.',
        );
      }
      final exportPassword = EncryptionService.generateExportPassword();

      final exportData = {
        'app_name': 'Noir Journal',
        'export_date': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'entries_count': entries.length,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      };
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      final encryptedData = await EncryptionService.encryptData(
        jsonString,
        exportPassword,
      );

      final encryptedContainer = {
        'app_name': 'Noir Journal',
        'format_version': '2.0',
        'encrypted': true,
        'export_date': DateTime.now().toIso8601String(),
        'encryption_info': encryptedData.toJson(),
      };

      final finalJsonString = const JsonEncoder.withIndent(
        '  ',
      ).convert(encryptedContainer);

      final directory =
          Platform.isAndroid
              ? Directory('/storage/emulated/0/Download')
              : await getApplicationDocumentsDirectory();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'noir_journal_encrypted_$timestamp.njb';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(finalJsonString);

      return ExportResult(
        success: true,
        message:
            'Successfully exported ${entries.length} journal entries to ${file.path}\n\nIMPORTANT: Your backup password is:\n$exportPassword\n\nSave this password securely - you\'ll need it to import your data!',
        entriesCount: entries.length,
        exportPassword: exportPassword,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Failed to export data: ${e.toString()}',
      );
    }
  }

  static Future<ImportResult> importData([String? password]) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        dialogTitle: 'Select Noir Journal Backup File (.njb or .json)',
        withData: false,
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult(success: false, message: 'No file selected.');
      }
      final filePath = result.files.first.path!;
      final fileName = result.files.first.name;

      debugPrint('Selected file: $fileName');
      debugPrint('File path: $filePath');
      if (!fileName.toLowerCase().endsWith('.njb') &&
          !fileName.toLowerCase().endsWith('.json')) {
        return ImportResult(
          success: false,
          message:
              'Invalid file type. Please select a Noir Journal backup file (.njb) or JSON backup file (.json).\n\nSelected file: $fileName',
        );
      }
      final file = File(filePath);
      final jsonString = await file.readAsString();

      debugPrint('File content length: ${jsonString.length}');
      debugPrint(
        'First 200 characters: ${jsonString.substring(0, jsonString.length > 200 ? 200 : jsonString.length)}',
      );

      final jsonData = jsonDecode(jsonString);

      if (jsonData is! Map<String, dynamic>) {
        return ImportResult(
          success: false,
          message: 'Invalid backup file format.',
        );
      }
      Map<String, dynamic> entriesData;
      if (jsonData.containsKey('encrypted') && jsonData['encrypted'] == true) {
        debugPrint('File is encrypted, checking password...');

        if (password == null || password.isEmpty) {
          debugPrint('No password provided for encrypted file');
          return ImportResult(
            success: false,
            message:
                'This backup is encrypted. Please provide the backup password.',
            needsPassword: true,
          );
        }

        try {
          debugPrint('Attempting to decrypt with provided password...');
          final encryptionInfo =
              jsonData['encryption_info'] as Map<String, dynamic>;
          debugPrint('Encryption info found: ${encryptionInfo.keys.toList()}');
          final encryptedData = EncryptedData.fromJson(encryptionInfo);
          debugPrint(
            '📥 IMPORT DEBUG: Created EncryptedData object, attempting decryption...',
          );
          final decryptedJsonString = await EncryptionService.decryptData(
            encryptedData,
            password,
          );

          debugPrint(
            '📥 IMPORT DEBUG: Decryption successful, parsing JSON (size: ${decryptedJsonString.length} chars)...',
          );
          entriesData = jsonDecode(decryptedJsonString) as Map<String, dynamic>;
          debugPrint(
            '📥 IMPORT DEBUG: Parsed entries data keys: ${entriesData.keys.toList()}',
          );
        } catch (e) {
          debugPrint('Decryption failed: $e');
          return ImportResult(
            success: false,
            message:
                'Failed to decrypt backup. Please check your password and try again.',
          );
        }
      } else {
        debugPrint('File is not encrypted, using direct data');
        entriesData = jsonData;
      }

      if (!entriesData.containsKey('entries') ||
          entriesData['entries'] is! List) {
        return ImportResult(
          success: false,
          message: 'No valid entries found in backup file.',
        );
      }

      final entriesList = entriesData['entries'] as List;
      final importedEntries = _processEntriesFromImport(entriesList);

      return _mergeAndSaveEntries(importedEntries);
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Failed to import data: ${e.toString()}',
      );
    }
  }

  static Future<FileCheckResult> checkBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        dialogTitle: 'Select Noir Journal Backup File (.njb or .json)',
        withData: false,
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) {
        return FileCheckResult(success: false, message: 'No file selected.');
      }

      final filePath = result.files.first.path!;
      final fileName = result.files.first.name;

      debugPrint('Selected file: $fileName');
      debugPrint('File path: $filePath');

      if (!fileName.toLowerCase().endsWith('.njb') &&
          !fileName.toLowerCase().endsWith('.json')) {
        return FileCheckResult(
          success: false,
          message:
              'Invalid file type. Please select a Noir Journal backup file (.njb) or JSON backup file (.json).\n\nSelected file: $fileName',
        );
      }

      final file = File(filePath);
      final jsonString = await file.readAsString();

      debugPrint('File content length: ${jsonString.length}');
      debugPrint(
        'First 200 characters: ${jsonString.substring(0, jsonString.length > 200 ? 200 : jsonString.length)}',
      );

      final jsonData = jsonDecode(jsonString);

      if (jsonData is! Map<String, dynamic>) {
        return FileCheckResult(
          success: false,
          message: 'Invalid backup file format.',
        );
      }

      final isEncrypted =
          jsonData.containsKey('encrypted') && jsonData['encrypted'] == true;
      return FileCheckResult(
        success: true,
        message: 'File checked successfully',
        filePath: filePath,
        fileName: fileName,
        isEncrypted: isEncrypted,
        jsonData: jsonData,
      );
    } catch (e) {
      return FileCheckResult(
        success: false,
        message: 'Failed to read backup file: ${e.toString()}',
      );
    }
  }

  static Future<ImportResult> importFromCheckedFile(
    FileCheckResult fileCheck, [
    String? password,
  ]) async {
    try {
      if (!fileCheck.success) {
        return ImportResult(success: false, message: fileCheck.message);
      }

      final jsonData = fileCheck.jsonData!;
      Map<String, dynamic> entriesData;

      if (fileCheck.isEncrypted) {
        if (password == null || password.isEmpty) {
          return ImportResult(
            success: false,
            message:
                'This backup is encrypted. Please provide the backup password.',
            needsPassword: true,
          );
        }

        try {
          final encryptionInfo =
              jsonData['encryption_info'] as Map<String, dynamic>;
          final encryptedData = EncryptedData.fromJson(encryptionInfo);
          final decryptedJsonString = await EncryptionService.decryptData(
            encryptedData,
            password,
          );

          entriesData = jsonDecode(decryptedJsonString) as Map<String, dynamic>;
        } catch (e) {
          return ImportResult(
            success: false,
            message:
                'Failed to decrypt backup. Please check your password and try again.',
          );
        }
      } else {
        entriesData = jsonData;
      }

      if (!entriesData.containsKey('entries') ||
          entriesData['entries'] is! List) {
        return ImportResult(
          success: false,
          message: 'No valid entries found in backup file.',
        );
      }

      final entriesList = entriesData['entries'] as List;
      final importedEntries = _processEntriesFromImport(entriesList);

      return _mergeAndSaveEntries(importedEntries);
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Failed to import data: ${e.toString()}',
      );
    }
  }

  // Helper method to process entries list from import data
  static List<DiaryEntry> _processEntriesFromImport(List entriesList) {
    final importedEntries = <DiaryEntry>[];

    for (final entryData in entriesList) {
      if (entryData is Map<String, dynamic>) {
        try {
          final entry = DiaryEntry.fromJson(entryData);
          importedEntries.add(entry);
        } catch (e) {
          debugPrint('Error parsing entry during import: $e');
          continue;
        }
      }
    }

    return importedEntries;
  }

  // Helper method to merge entries and create import result
  static Future<ImportResult> _mergeAndSaveEntries(
    List<DiaryEntry> importedEntries,
  ) async {
    if (importedEntries.isEmpty) {
      return ImportResult(
        success: false,
        message: 'No valid entries found in the backup file.',
      );
    }

    final existingEntries = await _loadAllEntries();
    final duplicateCount = _findDuplicates(existingEntries, importedEntries);
    final uniqueEntries = _removeDuplicates(existingEntries, importedEntries);

    final allEntries = [...existingEntries, ...uniqueEntries];
    allEntries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    await _saveAllEntries(allEntries);

    return ImportResult(
      success: true,
      message:
          duplicateCount > 0
              ? 'Successfully imported ${uniqueEntries.length} new entries. $duplicateCount duplicates were skipped.'
              : 'Successfully imported ${uniqueEntries.length} journal entries.',
      entriesCount: uniqueEntries.length,
      duplicatesSkipped: duplicateCount,
    );
  }

  static int _findDuplicates(
    List<DiaryEntry> existing,
    List<DiaryEntry> imported,
  ) {
    int duplicateCount = 0;
    for (final importedEntry in imported) {
      if (existing.any(
        (existingEntry) =>
            existingEntry.title == importedEntry.title &&
            existingEntry.createdAt == importedEntry.createdAt,
      )) {
        duplicateCount++;
      }
    }
    return duplicateCount;
  }

  static List<DiaryEntry> _removeDuplicates(
    List<DiaryEntry> existing,
    List<DiaryEntry> imported,
  ) {
    return imported.where((importedEntry) {
      return !existing.any(
        (existingEntry) =>
            existingEntry.title == importedEntry.title &&
            existingEntry.createdAt == importedEntry.createdAt,
      );
    }).toList();
  }
}

class FileCheckResult {
  final bool success;
  final String message;
  final String? filePath;
  final String? fileName;
  final bool isEncrypted;
  final Map<String, dynamic>? jsonData;

  FileCheckResult({
    required this.success,
    required this.message,
    this.filePath,
    this.fileName,
    this.isEncrypted = false,
    this.jsonData,
  });
}

class ExportResult {
  final bool success;
  final String message;
  final int? entriesCount;
  final String? exportPassword;

  ExportResult({
    required this.success,
    required this.message,
    this.entriesCount,
    this.exportPassword,
  });
}

class ImportResult {
  final bool success;
  final String message;
  final int? entriesCount;
  final int? duplicatesSkipped;
  final bool needsPassword;

  ImportResult({
    required this.success,
    required this.message,
    this.entriesCount,
    this.duplicatesSkipped,
    this.needsPassword = false,
  });
}
