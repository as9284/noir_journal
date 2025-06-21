import 'package:flutter/material.dart';

class EntryDescriptionSection extends StatelessWidget {
  final TextEditingController descriptionController;
  final bool isEditing;

  const EntryDescriptionSection({
    super.key,
    required this.descriptionController,
    required this.isEditing,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!isEditing) {
      // Immersive reading mode - just the description text without decorations
      return Text(
        descriptionController.text.isEmpty
            ? 'No description added'
            : descriptionController.text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color:
              descriptionController.text.isEmpty
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                  : theme.colorScheme.onSurface,
          fontStyle:
              descriptionController.text.isEmpty ? FontStyle.italic : null,
          height: 1.6, // Better line spacing for reading
        ),
      );
    }

    // Edit mode - keep the existing structure with description header and borders
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Description',
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
          constraints: const BoxConstraints(minHeight: 120),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withAlpha(77),
              width: 1,
            ),
          ),
          child: TextField(
            controller: descriptionController,
            maxLines: null,
            minLines: 5,
            decoration: InputDecoration(
              hintText: 'Tell me about your day...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withAlpha(128),
              ),
            ),
            style: theme.textTheme.bodyMedium,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
      ],
    );
  }
}
