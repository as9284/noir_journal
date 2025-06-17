import 'package:flutter/material.dart';

Future<String?> showUserNameDialog(
  BuildContext context, {
  String? initialName,
}) {
  final controller = TextEditingController(text: initialName ?? '');
  return showDialog<String>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const Text('Change Your Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(ctx, name);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
  );
}
