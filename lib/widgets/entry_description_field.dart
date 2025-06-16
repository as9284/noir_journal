import 'package:flutter/material.dart';
import '../constants/diary_icons.dart';
import '../constants/ui_constants.dart';

class EntryDescriptionField extends StatefulWidget {
  final bool editing;
  final TextEditingController controller;
  final String currentDescription;
  final Animation<double> editAnim;
  final bool isDark;
  final IconData selectedIcon;
  final ValueChanged<IconData>? onIconChanged;

  const EntryDescriptionField({
    super.key,
    required this.editing,
    required this.controller,
    required this.currentDescription,
    required this.editAnim,
    required this.isDark,
    required this.selectedIcon,
    this.onIconChanged,
  });

  @override
  State<EntryDescriptionField> createState() => _EntryDescriptionFieldState();
}

class _EntryDescriptionFieldState extends State<EntryDescriptionField> {
  @override
  void initState() {
    super.initState();
    widget.editAnim.addListener(_handleAnim);
  }

  @override
  void didUpdateWidget(covariant EntryDescriptionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.editAnim != widget.editAnim) {
      oldWidget.editAnim.removeListener(_handleAnim);
      widget.editAnim.addListener(_handleAnim);
    }
  }

  @override
  void dispose() {
    widget.editAnim.removeListener(_handleAnim);
    super.dispose();
  }

  void _handleAnim() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing;
    final controller = widget.controller;
    final currentDescription = widget.currentDescription;
    final editAnim = widget.editAnim;
    final isDark = widget.isDark;
    final selectedIcon = widget.selectedIcon;
    final onIconChanged = widget.onIconChanged;

    if (editing) {
      return Transform.translate(
        offset: Offset(0, 20 * (1 - editAnim.value)),
        child: Opacity(
          opacity: editAnim.value,
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? Colors.white10 : Colors.black12).withAlpha(30),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(
              horizontal: DiaryPaddings.horizontal,
              vertical: DiaryPaddings.vertical,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Editing',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (onIconChanged != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Choose an icon:',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.swipe,
                            size: 18,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Scroll',
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).hintColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 56,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DiaryPaddings.horizontal,
                      ),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children:
                            DiaryIcons.all.map((icon) {
                              final isSelected = icon == selectedIcon;
                              return GestureDetector(
                                onTap: () => onIconChanged(icon),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
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
                                              ? Theme.of(
                                                context,
                                              ).colorScheme.primary
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
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                            : Theme.of(context).iconTheme.color,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Scrollbar(
                      child: TextField(
                        key: const ValueKey('edit'),
                        controller: controller,
                        maxLines: null,
                        minLines: 3,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Write your thoughts...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 2,
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.15,
                          height: 1.5,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          key: const ValueKey('view'),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DiaryPaddings.horizontal,
              vertical: 2,
            ),
            child:
                currentDescription.isEmpty
                    ? Text(
                      'No description yet, please tap the edit icon to add one.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white54 : Colors.black54,
                        letterSpacing: 0.1,
                      ),
                      textAlign: TextAlign.left,
                    )
                    : Text(
                      currentDescription,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black,
                        letterSpacing: 0.15,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.left,
                    ),
          ),
        ),
      );
    }
  }
}
