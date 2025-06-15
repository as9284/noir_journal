import 'package:flutter/material.dart';

class IconPicker extends StatelessWidget {
  final IconData selectedIcon;
  final ValueChanged<IconData> onIconSelected;
  final List<IconData> icons;

  const IconPicker({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          icons.map((icon) {
            final isSelected = icon == selectedIcon;
            return GestureDetector(
              onTap: () => onIconSelected(icon),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary.withAlpha(30)
                          : Colors.transparent,
                  border: Border.all(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).iconTheme.color,
                ),
              ),
            );
          }).toList(),
    );
  }
}
