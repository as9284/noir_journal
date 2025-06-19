import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/diary_entry.dart';
import '../widgets/diary_entry_search_delegate.dart';
import '../screens/statistics_page.dart';
import '../screens/mood_tracker_page.dart';
import '../screens/entry_page.dart';

class AppDrawer extends StatefulWidget {
  final List<DiaryEntry> entries;
  final void Function(String query) onSearchTitle;
  final void Function(DateTime date, String type, DateTime? endDate)
  onSearchDate;
  final VoidCallback onSettings;

  const AppDrawer({
    super.key,
    required this.entries,
    required this.onSearchTitle,
    required this.onSearchDate,
    required this.onSettings,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = packageInfo.version;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _version = 'Unknown';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Drawer(
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.menu_book,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Noir Journal',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'SEARCH & DISCOVER',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ModernDrawerTile(
                    icon: Icons.search,
                    label: 'Smart Search',
                    subtitle: 'Search by title, content, or mood',
                    onTap: () async {
                      Navigator.pop(context);
                      final selectedEntry = await showSearch<DiaryEntry?>(
                        context: context,
                        delegate: DiaryEntrySearchDelegate(widget.entries),
                      );
                      if (selectedEntry != null && context.mounted) {
                        // Navigate to the entry page with proper update callback
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EntryPage(
                                  entry: selectedEntry,
                                  onUpdate: (updatedEntry) {
                                    // Find and update the entry in the list
                                    final index = widget.entries.indexWhere(
                                      (e) =>
                                          e.title == selectedEntry.title &&
                                          e.createdAt ==
                                              selectedEntry.createdAt,
                                    );
                                    if (index != -1) {
                                      widget.entries[index] = updatedEntry;
                                    }
                                  },
                                ),
                          ),
                        );
                      }
                    },
                    color: Colors.blue,
                  ),

                  _ModernDrawerTile(
                    icon: Icons.date_range,
                    label: 'Find by Date',
                    subtitle: 'Browse entries from specific dates',
                    onTap: () => _showDateSearchOptions(context),
                    color: Colors.green,
                  ),

                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'INSIGHTS & ANALYTICS',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _ModernDrawerTile(
                    icon: Icons.psychology,
                    label: 'Mood Tracker',
                    subtitle: 'Visualize your emotional journey',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MoodTrackerPage(),
                        ),
                      );
                    },
                    color: Colors.purple,
                  ),

                  _ModernDrawerTile(
                    icon: Icons.analytics_rounded,
                    label: 'Statistics',
                    subtitle: 'Detailed insights and trends',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StatisticsPage(),
                        ),
                      );
                    },
                    color: Colors.orange,
                  ),

                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'SETTINGS',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _ModernDrawerTile(
                    icon: Icons.settings,
                    label: 'Preferences',
                    subtitle: 'Customize your journal experience',
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSettings();
                    },
                    color: Colors.blueGrey,
                  ),

                  const Spacer(),

                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Version $_version',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Your thoughts, beautifully organized',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDateSearchOptions(BuildContext context) async {
    Navigator.pop(context);

    final option = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Search by Date'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DateSearchOption(
                  icon: Icons.today,
                  title: 'Specific Date',
                  subtitle: 'Find entries from a particular day',
                  onTap: () => Navigator.of(context).pop('specific'),
                ),
                const SizedBox(height: 8),
                _DateSearchOption(
                  icon: Icons.calendar_month,
                  title: 'This Month',
                  subtitle:
                      'Show all entries from ${DateTime.now().month}/${DateTime.now().year}',
                  onTap: () => Navigator.of(context).pop('month'),
                ),
                const SizedBox(height: 8),
                _DateSearchOption(
                  icon: Icons.date_range,
                  title: 'Date Range',
                  subtitle: 'Find entries within a time period',
                  onTap: () => Navigator.of(context).pop('range'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );

    if (option != null && context.mounted) {
      await _handleDateSearchOption(context, option);
    }
  }

  Future<void> _handleDateSearchOption(
    BuildContext context,
    String option,
  ) async {
    try {
      switch (option) {
        case 'specific':
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            helpText: 'Select a date to search',
          );
          if (picked != null && context.mounted) {
            debugPrint('Date search: picked date = $picked, type = exact');
            widget.onSearchDate(picked, 'exact', null);
          }
          break;

        case 'range':
          final range = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            helpText: 'Select date range',
          );
          if (range != null && context.mounted) {
            debugPrint(
              'Date search: picked range = ${range.start} to ${range.end}',
            );
            widget.onSearchDate(range.start, 'range', range.end);
          }
          break;

        case 'month':
          final now = DateTime.now();
          final startOfMonth = DateTime(now.year, now.month, 1);
          if (context.mounted) {
            debugPrint('Date search: this month = $startOfMonth');
            widget.onSearchDate(startOfMonth, 'month', null);
          }
          break;
      }
    } catch (e) {
      debugPrint('Error in date search: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting date: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _ModernDrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  const _ModernDrawerTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateSearchOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DateSearchOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
