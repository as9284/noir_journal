import 'package:flutter/material.dart';
import 'package:noir_journal/models/diary_entry.dart';
import 'package:noir_journal/models/mood.dart';
import '../widgets/entry_title_section.dart';
import '../widgets/entry_description_section.dart';
import '../widgets/entry_icon_section.dart';
import '../widgets/entry_mood_section.dart';

class CreateEntryPage extends StatefulWidget {
  const CreateEntryPage({super.key});

  @override
  State<CreateEntryPage> createState() => _CreateEntryPageState();
}

class _CreateEntryPageState extends State<CreateEntryPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  int _selectedIconIndex = 0;
  Mood? _selectedMood;
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateCanSave);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _updateCanSave() {
    setState(() {
      _canSave = _titleController.text.trim().isNotEmpty;
    });
  }

  void _saveEntry() {
    if (!_canSave) return;

    final entry = DiaryEntry(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
      iconIndex: _selectedIconIndex,
      mood: _selectedMood,
    );

    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('New Entry'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient:
                    _canSave
                        ? LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withValues(alpha: 0.8),
                          ],
                        )
                        : null,
                boxShadow:
                    _canSave
                        ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: TextButton.icon(
                onPressed: _canSave ? _saveEntry : null,
                icon: Icon(
                  Icons.check_rounded,
                  size: 18,
                  color:
                      _canSave
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                label: Text(
                  'Save',
                  style: TextStyle(
                    color:
                        _canSave
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor:
                      _canSave
                          ? Colors.transparent
                          : colorScheme.surface.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side:
                        _canSave
                            ? BorderSide.none
                            : BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.3),
                            ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient:
                isDark
                    ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.surface,
                        colorScheme.surface.withValues(alpha: 0.98),
                      ],
                      stops: const [0.0, 1.0],
                    )
                    : null,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with visual emphasis
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDark
                              ? [
                                colorScheme.primaryContainer.withValues(
                                  alpha: 0.3,
                                ),
                                colorScheme.primaryContainer.withValues(
                                  alpha: 0.1,
                                ),
                              ]
                              : [
                                colorScheme.primary.withValues(alpha: 0.05),
                                colorScheme.primary.withValues(alpha: 0.02),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isDark
                              ? colorScheme.primary.withValues(alpha: 0.2)
                              : colorScheme.primary.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? colorScheme.primary.withValues(alpha: 0.15)
                                  : colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.edit_note_rounded,
                          color: colorScheme.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create New Entry',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Capture your thoughts and memories',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Enhanced form sections with better spacing
                _buildEnhancedSection(
                  child: EntryTitleSection(
                    titleController: _titleController,
                    isEditing: true,
                  ),
                  theme: theme,
                ),
                const SizedBox(height: 24),

                _buildEnhancedSection(
                  child: EntryDescriptionSection(
                    descriptionController: _descriptionController,
                    isEditing: true,
                  ),
                  theme: theme,
                ),
                const SizedBox(height: 24),

                _buildEnhancedSection(
                  child: EntryMoodSection(
                    selectedMood: _selectedMood,
                    onMoodChanged: (mood) {
                      setState(() {
                        _selectedMood = mood;
                      });
                    },
                  ),
                  theme: theme,
                ),
                const SizedBox(height: 24),

                _buildEnhancedSection(
                  child: EntryIconSection(
                    selectedIconIndex: _selectedIconIndex,
                    onIconChanged: (index) {
                      setState(() {
                        _selectedIconIndex = index;
                      });
                    },
                  ),
                  theme: theme,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedSection({
    required Widget child,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            isDark
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDark
                  ? colorScheme.outline.withValues(alpha: 0.1)
                  : colorScheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: isDark ? 16 : 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}
