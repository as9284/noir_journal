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
      if (globalAppLockNotifier.value) {
        if (mounted) {
          setState(() {
            _locked = true;
          });
        }
      }
    }

    if (state == AppLifecycleState.resumed) {
      if (_locked) {
        _checkLock();
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
