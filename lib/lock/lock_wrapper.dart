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
  bool _appWasInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    globalAppLockNotifier.addListener(_onAppLockStateChanged);

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
    globalAppLockNotifier.removeListener(_onAppLockStateChanged);
    super.dispose();
  }

  void _onAppLockStateChanged() {
    if (mounted) {
      if (globalAppLockNotifier.value && !_locked) {
        if (globalFileOperationInProgress.value) {
          return;
        }
        setState(() {
          _locked = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkLock();
        });
      } else if (!globalAppLockNotifier.value && _locked) {
        setState(() {
          _locked = false;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      if (globalAppLockNotifier.value &&
          mounted &&
          !globalFileOperationInProgress.value) {
        _appWasInBackground = true;
      }
    }

    if (state == AppLifecycleState.resumed) {
      if (globalAppLockNotifier.value &&
          _appWasInBackground &&
          mounted &&
          !globalFileOperationInProgress.value) {
        _appWasInBackground = false;
        setState(() {
          _locked = true;
        });
        _checkLock();
      }
    }
  }

  Future<void> _checkLock() async {
    if (_isCheckingLock || !mounted) {
      return;
    }

    setState(() {
      _isCheckingLock = true;
    });

    final unlocked = await AppLockManager.requireAuthenticationForApp(context);

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
      return GestureDetector(
        onTap: () {
          if (!_isCheckingLock) {
            _checkLock();
          }
        },
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'App Locked',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to unlock',
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
      );
    }
    return widget.child;
  }
}
