import 'package:flutter/material.dart';
import '../constants/diary_icons.dart';

class EntryIconSection extends StatefulWidget {
  final int selectedIconIndex;
  final ValueChanged<int> onIconChanged;

  const EntryIconSection({
    super.key,
    required this.selectedIconIndex,
    required this.onIconChanged,
  });

  @override
  State<EntryIconSection> createState() => _EntryIconSectionState();
}

class _EntryIconSectionState extends State<EntryIconSection> {
  static const int _iconsPerPage = 30; // Show 30 icons initially (5 rows of 6)
  int _displayedIconsCount = _iconsPerPage;

  @override
  void initState() {
    super.initState();
    // If the selected icon is beyond the initial display count, expand to show it
    if (widget.selectedIconIndex >= _iconsPerPage) {
      _displayedIconsCount =
          ((widget.selectedIconIndex / _iconsPerPage).ceil() + 1) *
          _iconsPerPage;
      _displayedIconsCount = _displayedIconsCount.clamp(
        0,
        DiaryIcons.all.length,
      );
    }
  }

  void _loadMoreIcons() {
    setState(() {
      _displayedIconsCount = (_displayedIconsCount + _iconsPerPage).clamp(
        0,
        DiaryIcons.all.length,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasMoreIcons = _displayedIconsCount < DiaryIcons.all.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.emoji_emotions,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Choose an Icon',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const Spacer(),
            if (hasMoreIcons || _displayedIconsCount > _iconsPerPage)
              Text(
                '$_displayedIconsCount of ${DiaryIcons.all.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: _displayedIconsCount,
                itemBuilder: (context, index) {
                  final isSelected = index == widget.selectedIconIndex;
                  return GestureDetector(
                    onTap: () => widget.onIconChanged(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                )
                                : theme.colorScheme.primary.withValues(
                                  alpha: 0.05,
                                ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        DiaryIcons.all[index],
                        size: 24,
                        color:
                            isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                      ),
                    ),
                  );
                },
              ),
              if (hasMoreIcons) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _loadMoreIcons,
                    icon: const Icon(Icons.expand_more),
                    label: Text(
                      'Load More Icons (${DiaryIcons.all.length - _displayedIconsCount} remaining)',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
