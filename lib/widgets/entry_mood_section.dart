import 'package:flutter/material.dart';
import '../models/mood.dart';
import 'mood_selector.dart';

class EntryMoodSection extends StatelessWidget {
  final Mood? selectedMood;
  final ValueChanged<Mood?> onMoodChanged;
  const EntryMoodSection({
    super.key,
    required this.selectedMood,
    required this.onMoodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.mood, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Mood',
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withAlpha(77),
              width: 1,
            ),
          ),
          child: MoodSelector(
            selectedMood: selectedMood,
            onMoodChanged: onMoodChanged,
            title: 'How were you feeling?',
          ),
        ),
      ],
    );
  }
}
