import 'package:flutter/material.dart';
import '../models/mood.dart';

class MoodSelector extends StatefulWidget {
  final Mood? selectedMood;
  final ValueChanged<Mood?> onMoodChanged;
  final String title;

  const MoodSelector({
    super.key,
    this.selectedMood,
    required this.onMoodChanged,
    this.title = 'How are you feeling?',
  });

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title.isNotEmpty) ...[
          Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
        ],
        _buildMoodSection('Positive', MoodHelper.getPositiveMoods(), theme),
        const SizedBox(height: 16),
        _buildMoodSection('Neutral', MoodHelper.getNeutralMoods(), theme),
        const SizedBox(height: 16),
        _buildMoodSection('Challenging', MoodHelper.getNegativeMoods(), theme),
        if (widget.selectedMood != null) ...[
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => widget.onMoodChanged(null),
              icon: const Icon(Icons.clear_rounded, size: 18),
              label: const Text('Clear Selection'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurface.withValues(alpha: 0.7),
                side: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMoodSection(
    String sectionTitle,
    List<MoodData> moods,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            sectionTitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              moods.map((moodData) => _buildMoodChip(moodData, theme)).toList(),
        ),
      ],
    );
  }

  Widget _buildMoodChip(MoodData moodData, ThemeData theme) {
    final isSelected = widget.selectedMood == moodData.mood;
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (isSelected) {
            widget.onMoodChanged(null);
          } else {
            widget.onMoodChanged(moodData.mood);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? moodData.color.withValues(alpha: 0.15)
                    : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isSelected
                      ? moodData.color.withValues(alpha: 0.6)
                      : colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: moodData.color.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(moodData.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                moodData.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MoodDisplay extends StatelessWidget {
  final Mood mood;
  final double size;
  final bool showLabel;
  final EdgeInsetsGeometry? padding;

  const MoodDisplay({
    super.key,
    required this.mood,
    this.size = 24,
    this.showLabel = true,
    this.padding,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodData = MoodHelper.getMoodData(mood);

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: moodData.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: moodData.color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(moodData.emoji, style: TextStyle(fontSize: size)),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              moodData.name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                fontSize: size * 0.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
