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
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
