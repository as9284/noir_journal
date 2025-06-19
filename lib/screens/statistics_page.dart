import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';
import '../models/mood.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<DiaryEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList('diary_entries') ?? [];
      final entries =
          entriesJson
              .map((e) {
                try {
                  return DiaryEntry.fromJson(
                    Map<String, dynamic>.from(jsonDecode(e)),
                  );
                } catch (_) {
                  return null;
                }
              })
              .where((e) => e != null)
              .cast<DiaryEntry>()
              .toList();

      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int get _totalEntries => _entries.length;

  int get _totalWords => _entries.fold(0, (sum, entry) {
    final titleWords = entry.title.trim().split(RegExp(r'\s+'));
    final descWords = entry.description.trim().split(RegExp(r'\s+'));
    return sum + titleWords.length + descWords.length;
  });
  Map<Mood, int> get _moodCounts {
    final counts = <Mood, int>{};
    for (final entry in _entries) {
      if (entry.mood != null) {
        counts[entry.mood!] = (counts[entry.mood!] ?? 0) + 1;
      }
    }
    return counts;
  }

  int get _entriesThisMonth {
    final now = DateTime.now();
    return _entries.where((entry) {
      return entry.createdAt.year == now.year &&
          entry.createdAt.month == now.month;
    }).length;
  }

  int get _currentStreak {
    if (_entries.isEmpty) return 0;

    final today = DateTime.now();
    final sortedEntries =
        _entries.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int streak = 0;
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    for (final entry in sortedEntries) {
      final entryDate = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      if (entryDate.isAtSameMomentAs(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (entryDate.isBefore(checkDate)) {
        break;
      }
    }

    return streak;
  }

  double get _averageWordsPerEntry =>
      _totalEntries > 0 ? _totalWords / _totalEntries : 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _entries.isEmpty
              ? _buildEmptyState(theme)
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewSection(theme),
                    const SizedBox(height: 24),
                    _buildWritingStats(theme),
                    const SizedBox(height: 24),
                    _buildMoodStats(theme),
                    const SizedBox(height: 24),
                    _buildStreakSection(theme),
                  ],
                ),
              ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No Statistics Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start writing entries to see your statistics',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Overview',
      icon: Icons.dashboard_rounded,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              theme: theme,
              title: 'Total Entries',
              value: _totalEntries.toString(),
              icon: Icons.book_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              theme: theme,
              title: 'This Month',
              value: _entriesThisMonth.toString(),
              icon: Icons.calendar_month_rounded,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWritingStats(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Writing Statistics',
      icon: Icons.edit_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme: theme,
                  title: 'Total Words',
                  value: _totalWords.toString(),
                  icon: Icons.text_fields_rounded,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  theme: theme,
                  title: 'Avg Words/Entry',
                  value: _averageWordsPerEntry.toStringAsFixed(0),
                  icon: Icons.analytics_rounded,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodStats(ThemeData theme) {
    final moodCounts = _moodCounts;
    if (moodCounts.isEmpty) {
      return _buildSection(
        theme: theme,
        title: 'Mood Statistics',
        icon: Icons.mood_rounded,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              'No mood data available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      );
    }

    return _buildSection(
      theme: theme,
      title: 'Mood Statistics',
      icon: Icons.mood_rounded,
      child: Column(
        children:
            moodCounts.entries.map((entry) {
              final mood = entry.key;
              final count = entry.value;
              final percentage = (count / _totalEntries * 100).toStringAsFixed(
                1,
              );
              final moodData = MoodHelper.getMoodData(mood);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: moodData.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: moodData.color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: moodData.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        moodData.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            moodData.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$count entries ($percentage%)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: moodData.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        count.toString(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: moodData.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildStreakSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Writing Streak',
      icon: Icons.local_fire_department_rounded,
      child: _buildStatCard(
        theme: theme,
        title: 'Current Streak',
        value: '$_currentStreak ${_currentStreak == 1 ? 'day' : 'days'}',
        icon: Icons.local_fire_department_rounded,
        color: Colors.red,
        isFullWidth: true,
      ),
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
