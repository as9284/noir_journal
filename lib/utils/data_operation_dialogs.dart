import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dialog_utils.dart';

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
    try {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Silently handle any navigation errors
      debugPrint('Error hiding loading dialog: $e');
    }
  }

  static Future<bool> showExportConfirmation(
    BuildContext context,
    int entriesCount,
  ) async {
    if (entriesCount == 0) {
      await DialogUtils.showInfoDialog(
        context: context,
        title: 'Export Data',
        message: 'You have no journal entries to export.',
        icon: Icons.info_outline,
      );
      return false;
    }

    final result = await DialogUtils.showConfirmationDialog(
      context: context,
      title: 'Export Data',
      message:
          'This will export all your $entriesCount journal entries to a backup file that you can share or save.\n\nContinue?',
      confirmText: 'Export',
    );
    return result ?? false;
  }

  static Future<bool> showImportConfirmation(BuildContext context) async {
    final result = await DialogUtils.showConfirmationDialog(
      context: context,
      title: 'Import Data',
      message:
          'This will import journal entries from a backup file.\n\n'
          '• Your existing entries will not be deleted\n'
          '• Duplicate entries will be skipped automatically\n'
          '• Only valid journal entries will be imported\n\n'
          'Continue?',
      confirmText: 'Choose File',
    );
    return result ?? false;
  }

  static Future<void> showResultDialog(
    BuildContext context, {
    required bool success,
    required String title,
    required String message,
  }) async {
    if (!context.mounted) return;

    await DialogUtils.showInfoDialog(
      context: context,
      title: title,
      message: message,
      icon: success ? Icons.check_circle : Icons.error,
      iconColor: success ? Colors.green : Colors.red,
    );
  }
}
