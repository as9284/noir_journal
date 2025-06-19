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
            boxShadow:
                isEditing
                    ? []
                    : [
                      BoxShadow(
                        color: theme.shadowColor.withAlpha(25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            border: Border.all(
              color:
                  isEditing
                      ? theme.colorScheme.primary.withAlpha(77)
                      : theme.dividerColor.withAlpha(51),
              width: 1,
            ),
          ),
          child:
              isEditing
                  ? TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter title...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withAlpha(128),
                      ),
                    ),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  )
                  : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      titleController.text,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
        ),
      ],
    );
  }
}
