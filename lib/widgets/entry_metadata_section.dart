import 'package:flutter/material.dart';
import '../models/mood.dart';
import 'mood_selector.dart';

class EntryMetadataSection extends StatelessWidget {
  final DateTime createdAt;
  final Mood? mood;
  const EntryMetadataSection({super.key, required this.createdAt, this.mood});

  String _formatDateTime(DateTime dateTime) {
    final date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date at $time';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Clean, centered metadata without borders or containers
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDateTime(createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (mood != null) ...[
            const SizedBox(width: 12),
            MoodDisplay(
              mood: mood!,
              size: 14,
              showLabel: true,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            ),
          ],
        ],
      ),
    );
  }
}
