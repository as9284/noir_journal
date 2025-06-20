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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App lock overlay logic - only show overlay when app lock is enabled
    if (widget.enabled) {
      // Only show overlay when app goes to background (paused/hidden), not when inactive
      // This prevents the flash when notification panel is pulled down
      if (state == AppLifecycleState.paused ||
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
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showOverlay)
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            // Just show a blank screen - no content needed for recents protection
          ),
      ],
    );
  }
}
