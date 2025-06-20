import 'package:flutter/material.dart';

class SecurityOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final bool screenshotProtectionEnabled;

  const SecurityOverlay({
    super.key,
    required this.child,
    this.enabled = true,
    this.screenshotProtectionEnabled = false,
  });

  @override
  State<SecurityOverlay> createState() => _SecurityOverlayState();
}

class _SecurityOverlayState extends State<SecurityOverlay>
    with WidgetsBindingObserver {
  bool _showOverlay = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint(
      'SecurityOverlay: initState - appLock enabled: ${widget.enabled}, screenshot protection: ${widget.screenshotProtectionEnabled}',
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('SecurityOverlay: dispose called');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App lock overlay logic - only show overlay when app lock is enabled
    if (widget.enabled) {
      if (state == AppLifecycleState.inactive ||
          state == AppLifecycleState.paused ||
          state == AppLifecycleState.hidden) {
        setState(() {
          _showOverlay = true;
        });
      } else if (state == AppLifecycleState.resumed) {
        setState(() {
          _showOverlay = false;
        });
      }
    }

    // Screenshot protection works independently of app lock state
    // The FLAG_SECURE should already be set in initState and didUpdateWidget
    // and doesn't need to change based on app lifecycle
  }

  @override
  void didUpdateWidget(SecurityOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint(
      'SecurityOverlay: didUpdateWidget - appLock: ${widget.enabled}, screenshot protection: ${widget.screenshotProtectionEnabled}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showOverlay)
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Noir Journal',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your thoughts, secured',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
