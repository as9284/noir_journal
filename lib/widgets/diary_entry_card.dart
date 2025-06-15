import 'package:flutter/material.dart';
import 'package:noir_journal/models/diary_entry.dart';
import 'package:noir_journal/theme/app_theme.dart';

class DiaryEntryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;
  final DismissDirectionCallback? onDismissed;
  final Future<bool?> Function(DismissDirection)? confirmDismiss;
  final EdgeInsetsGeometry? padding;

  const DiaryEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.onDismissed,
    this.confirmDismiss,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final entryKey = '${entry.title}_${entry.createdAt.toIso8601String()}';

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Dismissible(
          key: Key(entryKey),
          direction: DismissDirection.horizontal,
          background: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          secondaryBackground: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.delete, color: Colors.red),
              ],
            ),
          ),
          confirmDismiss: confirmDismiss,
          onDismissed: onDismissed,
          child: Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? entryCardDarkColor
                    : entryCardLightColor,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: Theme.of(context).colorScheme.primary.withAlpha(20),
              highlightColor: Colors.transparent,
              onTap: onTap,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                title: Text(
                  entry.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
