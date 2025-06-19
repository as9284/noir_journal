import 'package:flutter/material.dart';

class EntryDescriptionSection extends StatelessWidget {
  final TextEditingController descriptionController;
  final bool isEditing;
  final bool expandToFill;

  const EntryDescriptionSection({
    super.key,
    required this.descriptionController,
    required this.isEditing,
    this.expandToFill = false,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (expandToFill) {
      // Expanded layout for non-edit mode
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                size: 20,
                color: theme.colorScheme.primary,
              ),
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
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withAlpha(25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: theme.dividerColor.withAlpha(51),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Text(
                    descriptionController.text.isEmpty
                        ? 'No description added'
                        : descriptionController.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          descriptionController.text.isEmpty
                              ? theme.colorScheme.onSurface.withAlpha(128)
                              : theme.colorScheme.onSurface,
                      fontStyle:
                          descriptionController.text.isEmpty
                              ? FontStyle.italic
                              : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Regular layout (for edit mode and non-expanded view)
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
          constraints: BoxConstraints(minHeight: isEditing ? 120 : 80),
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
                  )
                  : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      descriptionController.text.isEmpty
                          ? 'No description added'
                          : descriptionController.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            descriptionController.text.isEmpty
                                ? theme.colorScheme.onSurface.withAlpha(128)
                                : theme.colorScheme.onSurface,
                        fontStyle:
                            descriptionController.text.isEmpty
                                ? FontStyle.italic
                                : null,
                      ),
                    ),
                  ),
        ),
      ],
    );
  }
}
