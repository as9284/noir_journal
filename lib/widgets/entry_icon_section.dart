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
    final colorScheme = theme.colorScheme;
    final hasMoreIcons = _displayedIconsCount < DiaryIcons.all.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.emoji_emotions_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose an Icon',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pick an icon that represents your entry',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            if (hasMoreIcons || _displayedIconsCount > _iconsPerPage)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_displayedIconsCount of ${DiaryIcons.all.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Selected icon display
              if (widget.selectedIconIndex < DiaryIcons.all.length) ...[
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    DiaryIcons.all[widget.selectedIconIndex],
                    size: 40,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Icon grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _displayedIconsCount,
                itemBuilder: (context, index) {
                  final isSelected = index == widget.selectedIconIndex;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => widget.onIconChanged(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? colorScheme.primary.withValues(alpha: 0.15)
                                  : colorScheme.surface.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected
                                    ? colorScheme.primary
                                    : colorScheme.outline.withValues(
                                      alpha: 0.3,
                                    ),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Icon(
                          DiaryIcons.all[index],
                          size: 24,
                          color:
                              isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
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
                    icon: const Icon(Icons.expand_more_rounded),
                    label: Text(
                      'Load More Icons (${DiaryIcons.all.length - _displayedIconsCount} remaining)',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      backgroundColor: colorScheme.surface.withValues(
                        alpha: 0.5,
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
