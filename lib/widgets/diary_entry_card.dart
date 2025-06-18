import 'package:flutter/material.dart';
import 'package:noir_journal/models/diary_entry.dart';
import 'package:noir_journal/widgets/mood_selector.dart';

class DiaryEntryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;
  final bool selected;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final bool isInGroup;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const DiaryEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.onLongPress,
    this.selected = false,
    this.padding,
    this.isInGroup = false,
    this.isFirstInGroup = false,
    this.isLastInGroup = false,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isInGroup) {
      return _buildGroupedCard(theme);
    } else {
      return _buildStandaloneCard(theme);
    }
  }

  Widget _buildGroupedCard(ThemeData theme) {
    BorderRadius? borderRadius;
    if (selected) {
      if (isFirstInGroup && isLastInGroup) {
        borderRadius = BorderRadius.circular(12);
      } else if (isFirstInGroup) {
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        );
      } else if (isLastInGroup) {
        borderRadius = const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        );
      }
    }

    return Container(
      decoration:
          selected
              ? BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(25),
                border: Border.all(color: theme.colorScheme.primary, width: 2),
                borderRadius: borderRadius,
              )
              : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: _buildCardContent(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildStandaloneCard(ThemeData theme) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          color:
              selected
                  ? theme.colorScheme.primary.withAlpha(25)
                  : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              selected
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
                selected
                    ? theme.colorScheme.primary
                    : theme.dividerColor.withAlpha(51),
            width: selected ? 2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            onLongPress: onLongPress,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: _buildCardContent(theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color:
                selected
                    ? theme.colorScheme.primary.withAlpha(51)
                    : theme.colorScheme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(entry.icon, size: 24, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (entry.mood != null) ...[
                    const SizedBox(width: 8),
                    MoodDisplay(
                      mood: entry.mood!,
                      size: 16,
                      showLabel: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                    ),
                  ],
                ],
              ),
              if (entry.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  entry.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 4),
              Text(
                _formatTime(entry.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(102),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (selected)
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: 18,
              color: theme.colorScheme.onPrimary,
            ),
          )
        else
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurface.withAlpha(102),
            size: 20,
          ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
