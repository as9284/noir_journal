import 'package:flutter/material.dart';
import '../constants/diary_icons.dart';

Future<int?> showIconPickerDialog(
  BuildContext context, {
  int? initialIndex,
}) async {
  int selectedIndex = initialIndex ?? 0;
  return showDialog<int>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Choose an icon'),
          content: SizedBox(
            width: double.maxFinite,
            height: 120,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: DiaryIcons.all.length,
              itemBuilder: (context, index) {
                final icon = DiaryIcons.all[index];
                final isSelected = index == selectedIndex;
                return GestureDetector(
                  onTap: () {
                    selectedIndex = index;
                    Navigator.pop(context, selectedIndex);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(30)
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
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Skip'),
            ),
          ],
        ),
  );
}
