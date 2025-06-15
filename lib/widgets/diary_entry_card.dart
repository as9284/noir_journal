import 'package:flutter/material.dart';
import 'package:noir_journal/models/diary_entry.dart';
import 'package:noir_journal/theme/app_theme.dart';

class DiaryEntryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;
  final bool selected;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;

  const DiaryEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.onLongPress,
    this.selected = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: selected ? 0 : 4,
        color:
            selected
                ? Theme.of(context).colorScheme.primary.withAlpha(30)
                : (Theme.of(context).brightness == Brightness.dark
                    ? entryCardDarkColor
                    : entryCardLightColor),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration:
              selected
                  ? BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.5,
                    ),
                  )
                  : null,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: Theme.of(context).colorScheme.primary.withAlpha(20),
            highlightColor: Colors.transparent,
            onTap: onTap,
            onLongPress: onLongPress,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              leading: Icon(
                entry.icon,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                entry.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              trailing:
                  selected
                      ? const Icon(Icons.check_circle, color: Colors.red)
                      : null,
            ),
          ),
        ),
      ),
    );
  }
}
