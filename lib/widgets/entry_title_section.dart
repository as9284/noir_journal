import 'package:flutter/material.dart';

class EntryTitleSection extends StatelessWidget {
  final TextEditingController titleController;
  final bool isEditing;
  const EntryTitleSection({
    super.key,
    required this.titleController,
    required this.isEditing,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!isEditing) {
      // Immersive reading mode - just the title text without decorations
      return Text(
        titleController.text,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      );
    }

    // Edit mode - keep the existing structure with title header and borders
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.title, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Title',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Enter title...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
      ],
    );
  }
}
