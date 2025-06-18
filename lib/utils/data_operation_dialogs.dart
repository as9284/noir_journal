import 'package:flutter/material.dart';

class DataOperationDialogs {
  static Future<void> showLoadingDialog(
    BuildContext context,
    String message,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Text(message),
              ],
            ),
          ),
        );
      },
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  static Future<bool> showExportConfirmation(
    BuildContext context,
    int entriesCount,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Data'),
            content: Text(
              entriesCount == 0
                  ? 'You have no journal entries to export.'
                  : 'This will export all your $entriesCount journal entries to a backup file that you can share or save.\n\nContinue?',
            ),
            actions: [
              if (entriesCount > 0) ...[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Export'),
                ),
              ] else ...[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('OK'),
                ),
              ],
            ],
          ),
    );
    return result ?? false;
  }

  static Future<bool> showImportConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Import Data'),
            content: const Text(
              'This will import journal entries from a backup file.\n\n'
              '• Your existing entries will not be deleted\n'
              '• Duplicate entries will be skipped automatically\n'
              '• Only valid journal entries will be imported\n\n'
              'Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Choose File'),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  static Future<void> showResultDialog(
    BuildContext context, {
    required bool success,
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(title),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
