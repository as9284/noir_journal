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
    final Map<String, List<DiaryEntry>> grouped = {};
    for (final entry in entries) {
      final dateKey = _formatDate(entry.createdAt);
      grouped.putIfAbsent(dateKey, () => []).add(entry);
    }
    final dateKeys = grouped.keys.toList();
    dateKeys.sort((a, b) {
      // Custom order: Today > Yesterday > others (descending)
      if (a == b) return 0;
      if (a == 'Today') return -1;
      if (b == 'Today') return 1;
      if (a == 'Yesterday') return -1;
      if (b == 'Yesterday') return 1;
      return b.compareTo(a); // Descending for other dates
    }); // Most recent group first
    for (final key in grouped.keys) {
      grouped[key]!.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      ); // Newest entry first within group
    }
    return ListView.builder(
      itemCount: grouped.length + entries.length,
      itemBuilder: (context, index) {
        int runningIndex = 0;
        for (final dateKey in dateKeys) {
          // Heading
          if (index == runningIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                dateKey,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            );
          }
          runningIndex++;
          // Entries
          for (final entry in grouped[dateKey]!) {
            if (index == runningIndex) {
              return DiaryEntryCard(
                entry: entry,
                onTap: () => onTap(entry),
                onLongPress: () => onLongPress?.call(entry),
                selected: selectedEntries?.contains(entry) ?? false,
                padding: const EdgeInsets.symmetric(vertical: 6.0),
              );
            }
            runningIndex++;
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDay = DateTime(date.year, date.month, date.day);
    if (entryDay == today) {
      return 'Today';
    }
    final yesterday = today.subtract(const Duration(days: 1));
    if (entryDay == yesterday) {
      return 'Yesterday';
    }
    // Example: Monday, Jun 16, 2025
    final weekDay =
        [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ][date.weekday - 1];
    final month =
        [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ][date.month - 1];
    return '$weekDay, $month ${date.day}, ${date.year}';
  }
}
