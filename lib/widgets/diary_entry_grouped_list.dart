import 'package:flutter/material.dart';
import 'package:noir_journal/models/diary_entry.dart';
import 'package:noir_journal/widgets/diary_entry_card.dart';

class DiaryEntryGroupedList extends StatelessWidget {
  final List<DiaryEntry> entries;
  final void Function(DiaryEntry) onTap;
  final void Function(DiaryEntry)? onLongPress;
  final Set<DiaryEntry>? selectedEntries;

  const DiaryEntryGroupedList({
    super.key,
    required this.entries,
    required this.onTap,
    this.onLongPress,
    this.selectedEntries,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Map<String, List<DiaryEntry>> grouped = {};
    for (final entry in entries) {
      final dateKey = _formatDate(entry.createdAt);
      grouped.putIfAbsent(dateKey, () => []).add(entry);
    }

    final dateKeys = grouped.keys.toList();
    dateKeys.sort((a, b) {
      if (a == b) return 0;
      if (a == 'Today') return -1;
      if (b == 'Today') return 1;
      if (a == 'Yesterday') return -1;
      if (b == 'Yesterday') return 1;
      return b.compareTo(a);
    });

    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          dateKeys.map((dateKey) {
            final entriesForDate = grouped[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(theme, dateKey, entriesForDate.length),
                const SizedBox(height: 12),
                _buildEntriesCard(theme, entriesForDate),
                const SizedBox(height: 24),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, int count) {
    IconData icon;
    switch (title) {
      case 'Today':
        icon = Icons.today;
        break;
      case 'Yesterday':
        icon = Icons.access_time;
        break;
      default:
        icon = Icons.calendar_today;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesCard(ThemeData theme, List<DiaryEntry> entries) {
    return Container(
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
        border: Border.all(color: theme.dividerColor.withAlpha(51), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children:
              entries.asMap().entries.map((entryWithIndex) {
                final index = entryWithIndex.key;
                final entry = entryWithIndex.value;
                final isFirst = index == 0;
                final isLast = index == entries.length - 1;

                return Column(
                  children: [
                    DiaryEntryCard(
                      entry: entry,
                      onTap: () => onTap(entry),
                      onLongPress:
                          onLongPress != null
                              ? () => onLongPress!(entry)
                              : null,
                      selected: selectedEntries?.contains(entry) ?? false,
                      isInGroup: true,
                      isFirstInGroup: isFirst,
                      isLastInGroup: isLast,
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        color: theme.dividerColor.withAlpha(77),
                        indent: 16,
                        endIndent: 16,
                      ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final entryDate = DateTime(date.year, date.month, date.day);
  if (entryDate == today) return 'Today';
  if (entryDate == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
