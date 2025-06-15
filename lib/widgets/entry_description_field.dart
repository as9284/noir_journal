import 'package:flutter/material.dart';

class EntryDescriptionField extends StatefulWidget {
  final bool editing;
  final TextEditingController controller;
  final String currentDescription;
  final Animation<double> editAnim;
  final bool isDark;

  const EntryDescriptionField({
    super.key,
    required this.editing,
    required this.controller,
    required this.currentDescription,
    required this.editAnim,
    required this.isDark,
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
    if (editing) {
      return Opacity(
        opacity: editAnim.value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - editAnim.value)),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedOpacity(
                  opacity: editAnim.value,
                  duration: const Duration(milliseconds: 200),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Editing',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedOpacity(
                  opacity: editAnim.value,
                  duration: const Duration(milliseconds: 200),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: TextField(
                      key: const ValueKey('edit'),
                      controller: controller,
                      maxLines: null,
                      minLines: 12,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Write your thoughts...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(right: 4, top: 2),
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
            padding: const EdgeInsets.only(right: 4, top: 2),
            child:
                currentDescription.isEmpty
                    ? Text(
                      'No description yet. Tap the edit icon to add one.',
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
