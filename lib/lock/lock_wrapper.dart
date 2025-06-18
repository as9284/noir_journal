import 'package:flutter/material.dart';
import '../main.dart';
import 'app_lock_manager.dart';

class LockWrapper extends StatefulWidget {
  final Widget child;
  const LockWrapper({super.key, required this.child});

  @override
  State<LockWrapper> createState() => _LockWrapperState();
}

class _LockWrapperState extends State<LockWrapper> with WidgetsBindingObserver {
  bool _locked = false;
  bool _isCheckingLock = false;
  DateTime? _lastUnlockTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (globalAppLockNotifier.value) {
      _locked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkLock();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (globalAppLockNotifier.value && mounted) {
        setState(() {
          _locked = true;
        });
      }
    }

    if (state == AppLifecycleState.resumed) {
      if (_locked && mounted) {
        // Only check lock if enough time has passed since last unlock
        // This prevents immediate re-locking after operations like import
        final now = DateTime.now();
        final shouldCheckLock =
            _lastUnlockTime == null ||
            now.difference(_lastUnlockTime!).inSeconds > 5;

        if (shouldCheckLock) {
          _checkLock();
        } else {
          // Reset lock state without showing lock screen
          setState(() {
            _locked = false;
          });
        }
      }
    }
  }

  Future<void> _checkLock() async {
    if (_isCheckingLock || !mounted) return;

    setState(() {
      _isCheckingLock = true;
    });

    final unlocked = await AppLockManager.checkAndUnlock(context);
    if (mounted) {
      setState(() {
        _locked = !unlocked;
        _isCheckingLock = false;
      });

      // Record successful unlock time
      if (unlocked) {
        _lastUnlockTime = DateTime.now();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_locked) {
      return Container(color: Theme.of(context).scaffoldBackgroundColor);
    }
    return widget.child;
  }
}
