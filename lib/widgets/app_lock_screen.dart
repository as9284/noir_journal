import 'package:flutter/material.dart';
import 'dart:async';
import 'package:local_auth/local_auth.dart';
import '../utils/app_lock_service.dart';

enum AppLockAction { unlock, cancel }

typedef AppLockCallback = Future<bool> Function();
typedef CancelCallback = Future<void> Function();

class AppLockScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool showCancelButton;
  final String cancelButtonText;
  final AppLockCallback? onCancel;
  final bool allowBiometric;
  const AppLockScreen({
    super.key,
    this.title = 'App Locked',
    this.subtitle = 'Enter your PIN to continue',
    this.showCancelButton = false,
    this.cancelButtonText = 'Cancel',
    this.onCancel,
    this.allowBiometric = false,
  });

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  String _pin = '';
  String? _error;
  bool _isLoading = false;
  bool _biometricAttempted = false;
  bool _isInLockdown = false;
  int _lockdownSeconds = 0;
  Timer? _lockdownTimer;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkLockdownStatus();
    if (widget.allowBiometric) {
      _isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_biometricAttempted && !_isInLockdown) {
          // Remove delay for immediate biometric authentication
          _biometricAttempted = true;
          _handleBiometric();
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _lockdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkLockdownStatus() async {
    final inLockdown = await AppLockService.isInLockdown();
    final seconds = await AppLockService.getLockdownRemainingSeconds();

    if (mounted) {
      setState(() {
        _isInLockdown = inLockdown;
        _lockdownSeconds = seconds;
        if (inLockdown) {
          _error =
              'Too many failed attempts. Try again in $_lockdownSeconds seconds.';
          _startLockdownTimer();
        }
      });
    }
  }

  void _startLockdownTimer() {
    _lockdownTimer?.cancel();
    if (_lockdownSeconds > 0) {
      _lockdownTimer = Timer.periodic(const Duration(seconds: 1), (
        timer,
      ) async {
        if (!mounted) {
          timer.cancel();
          return;
        }

        final stillInLockdown = await AppLockService.isInLockdown();
        final remainingSeconds =
            await AppLockService.getLockdownRemainingSeconds();
        setState(() {
          _isInLockdown = stillInLockdown;
          _lockdownSeconds = remainingSeconds;

          if (stillInLockdown && remainingSeconds > 0) {
            _error =
                'Too many failed attempts. Try again in $_lockdownSeconds seconds.';
          } else if (remainingSeconds <= 0 || !stillInLockdown) {
            // Lockdown has ended, reset everything
            timer.cancel();
            _lockdownTimer = null;
            _isInLockdown = false;
            _lockdownSeconds = 0;
            _error = null;
            _pin = '';
          }
        });
      });
    }
  }

  void _onKeyTap(String value) {
    if (_pin.length < 6 && !_isLoading && !_isInLockdown) {
      setState(() {
        _pin += value;
        _error = null;
      });
      if (_pin.length == 6) {
        _submit();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty && !_isLoading && !_isInLockdown) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _error = null;
      });
    }
  }

  Future<void> _handleBiometric() async {
    if (!mounted || _isInLockdown) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    bool didAuthenticate = false;
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isAvailable = await _localAuth.isDeviceSupported();

      if (!canCheck || !isAvailable) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to unlock',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: false,
          stickyAuth: false,
        ),
      );

      if (didAuthenticate && mounted) {
        await AppLockService.resetFailedAttempts();
        await _animateAndPop(AppLockAction.unlock);
      }
    } catch (e) {
      debugPrint('Biometric authentication failed: $e');
    } finally {
      if (mounted && !didAuthenticate) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final pin = await AppLockService.getPin();
    final valid = _pin == pin;

    if (valid) {
      await AppLockService.resetFailedAttempts();
      if (!mounted) return;
      await _animateAndPop(AppLockAction.unlock);
    } else {
      await AppLockService.incrementFailedAttempts();

      final futures = await Future.wait([
        AppLockService.isInLockdown(),
        AppLockService.getLockdownRemainingSeconds(),
        AppLockService.getFailedAttempts(),
      ]);

      final inLockdown = futures[0] as bool;
      final seconds = futures[1] as int;
      final currentAttempts = futures[2] as int;
      final remaining =
          AppLockService.maxAttemptsBeforeLockdown - currentAttempts;

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInLockdown = inLockdown;
          _lockdownSeconds = seconds;

          if (inLockdown) {
            _error =
                'Too many failed attempts. Try again in $_lockdownSeconds seconds.';
            _startLockdownTimer();
          } else {
            _error = 'Incorrect PIN. $remaining attempts remaining.';
          }
          _pin = '';
        });
      }
    }
  }

  Future<void> _animateAndPop(AppLockAction action) async {
    // Remove delay for immediate unlock
    if (mounted) Navigator.of(context).pop(action);
  }

  Future<void> _handleCancel() async {
    if (widget.onCancel != null) {
      final shouldProceed = await widget.onCancel!();
      if (shouldProceed && mounted) {
        Navigator.of(context).pop(AppLockAction.cancel);
      }
    } else {
      if (mounted) {
        Navigator.of(context).pop(AppLockAction.cancel);
      }
    }
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        final filled = i < _pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color:
                filled
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
            border: Border.all(
              color:
                  filled ? Theme.of(context).colorScheme.primary : Colors.grey,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['biometric', '0', '<'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children:
          keys.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    row.map((key) {
                      if (key == '') {
                        return const SizedBox(width: 66, height: 66);
                      }
                      if (key == '<') {
                        return _PinBackspaceButton(onTap: _onBackspace);
                      }
                      if (key == 'biometric') {
                        // Show biometric button only if conditions are met
                        if (!_isLoading &&
                            widget.allowBiometric &&
                            !_isInLockdown &&
                            _biometricAttempted) {
                          return _PinBiometricButton(onTap: _handleBiometric);
                        } else {
                          return const SizedBox(width: 66, height: 66);
                        }
                      }
                      return _PinKeyButton(
                        value: key,
                        onTap: () => _onKeyTap(key),
                      );
                    }).toList(),
              ),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          automaticallyImplyLeading: false,
          centerTitle: true,
          elevation: 0,
          actions:
              widget.showCancelButton
                  ? [
                    TextButton(
                      onPressed: _isInLockdown ? null : _handleCancel,
                      child: Text(widget.cancelButtonText),
                    ),
                  ]
                  : null,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      kToolbarHeight -
                      32, // Account for SafeArea and AppBar
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.subtitle,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        _buildPinDots(),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 40),
                    Center(child: _buildKeypad()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinKeyButton extends StatefulWidget {
  final String value;
  final VoidCallback onTap;

  const _PinKeyButton({required this.value, required this.onTap});

  @override
  State<_PinKeyButton> createState() => _PinKeyButtonState();
}

class _PinKeyButtonState extends State<_PinKeyButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails _) {
    setState(() => _scale = 0.95);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: widget.onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: SizedBox(
            width: 66,
            height: 66,
            child: Center(
              child: Text(
                widget.value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinBackspaceButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PinBackspaceButton({required this.onTap});

  @override
  State<_PinBackspaceButton> createState() => _PinBackspaceButtonState();
}

class _PinBackspaceButtonState extends State<_PinBackspaceButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails _) => setState(() => _scale = 0.95);
  void _onTapUp(TapUpDetails _) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: widget.onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: SizedBox(
            width: 66,
            height: 66,
            child: Center(
              child: Icon(
                Icons.backspace_outlined,
                size: 26,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinBiometricButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PinBiometricButton({required this.onTap});

  @override
  State<_PinBiometricButton> createState() => _PinBiometricButtonState();
}

class _PinBiometricButtonState extends State<_PinBiometricButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails _) => setState(() => _scale = 0.95);
  void _onTapUp(TapUpDetails _) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: widget.onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: SizedBox(
            width: 66,
            height: 66,
            child: Center(
              child: Icon(
                Icons.fingerprint,
                size: 26,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
