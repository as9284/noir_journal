import 'package:flutter/material.dart';

class PasswordInputDialog {
  static Future<String?> showPasswordDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? hintText,
  }) async {
    final controller = TextEditingController();
    bool obscureText = true;

    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Row(
                    children: [
                      const Icon(Icons.lock, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(child: Text(title)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller,
                        obscureText: obscureText,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Backup Password',
                          hintText: hintText ?? 'Enter your backup password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                          ),
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            Navigator.of(context).pop(value.trim());
                          }
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final password = controller.text.trim();
                        if (password.isNotEmpty) {
                          Navigator.of(context).pop(password);
                        }
                      },
                      child: const Text('Import'),
                    ),
                  ],
                ),
          ),
    );
  }

  static Future<void> showPasswordCopyDialog(
    BuildContext context,
    String password,
  ) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.key, color: Colors.green),
                SizedBox(width: 8),
                Text('Backup Password'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'IMPORTANT: Save this password securely!\n\n'
                  'You will need this password to import your backup data. '
                  'If you lose this password, your backup cannot be restored.\n\n'
                  'Your backup password is:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[600]!),
                  ),
                  child: SelectableText(
                    password,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tap and hold the password above to select and copy it.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('I\'ve Saved It'),
              ),
            ],
          ),
    );
  }
}
