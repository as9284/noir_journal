import 'package:flutter/material.dart';
import '../constants/diary_icons.dart';

class EntryHeaderSection extends StatelessWidget {
  final int selectedIconIndex;
  final DateTime createdAt;
  const EntryHeaderSection({
    super.key,
    required this.selectedIconIndex,
    required this.createdAt,
  });

  String _getWeekday(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeString =
        '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    final dateString =
        '${_getWeekday(createdAt.weekday)}, ${_getMonth(createdAt.month)} ${createdAt.day}';

    // Clean, immersive header without borders or containers
    return Row(
      children: [
        // Simple icon without container decorations
        Icon(
          DiaryIcons.all[selectedIconIndex],
          size: 32,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                timeString,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateString,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
