import 'package:flutter/material.dart';

Future<String?> showTitleDialog(BuildContext context) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('New Diary Entry'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
  );
}

Future<String?> showDescriptionDialog(BuildContext context) async {
  final descController = TextEditingController();
  return showDialog<String>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Describe your day'),
          content: TextField(
            controller: descController,
            autofocus: true,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed:
                  () => Navigator.pop(context, descController.text.trim()),
              child: const Text('Save'),
            ),
          ],
        ),
  );
}
