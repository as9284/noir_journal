import 'package:flutter/material.dart';
import 'package:noir_journal/theme/app_theme.dart';

class EntryPage extends StatelessWidget {
  final String title;
  const EntryPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: isDark ? entryCardDarkColor : entryCardLightColor,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.book_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                // ...add more fields here later...
              ],
            ),
          ),
        ),
      ),
    );
  }
}
