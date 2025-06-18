import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:local_auth/local_auth.dart';
import '../utils/app_lock_service.dart';

class PinLockScreen extends StatefulWidget {
  final Future<bool> Function(String pin)? onVerify;
  final bool allowBiometric;
  final VoidCallback? onBiometric;
  final bool registerMode;
  final Future<void> Function(String pin)? onRegister;

  const PinLockScreen({
    super.key,
    this.onVerify,
    this.allowBiometric = false,
    this.onBiometric,
    this.registerMode = false,
    this.onRegister,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _pin = '';
  String? _error;
  bool _isLoading = false;
  String? _firstPin;
  bool _biometricAttempted = false;
  bool _isInLockdown = false;
  int _lockdownSeconds = 0;
  Timer? _lockdownTimer;
  final LocalAuthentication _localAuth = LocalAuthentication();
  @override
  void initState() {
    super.initState();
    _biometricAttempted = false;
    _checkLockdownStatus();

    if (widget.allowBiometric && !widget.registerMode) {
      _isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_biometricAttempted && !_isInLockdown) {
          _biometricAttempted = true;
          _handleBiometric();
        }
      });
    }
  }

  Future<void> _checkLockdownStatus() async {
    if (!widget.registerMode) {
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
          } else if (remainingSeconds <= 0) {
            // Close the app when lockdown timer reaches 0
            timer.cancel();
            _lockdownTimer = null;
            exit(0);
          } else {
            _error = null;
            timer.cancel();
            _lockdownTimer = null;
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
    if (!mounted) return;

    // Check if in lockdown before attempting biometric auth
    if (_isInLockdown) {
      setState(() {
        _error =
            'Too many failed attempts. Try again in $_lockdownSeconds seconds.';
      });
      return;
    }

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
            _error = 'Biometric authentication is not available.';
          });
        }
        return;
      }
      didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to unlock',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: false,
        ),
      );
      if (didAuthenticate && mounted) {
        // Reset failed attempts on successful biometric verification
        await AppLockService.resetFailedAttempts();
        await _animateAndPop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Biometric error: ${e.toString()}';
        });
      }
    } finally {
      if (mounted && !didAuthenticate) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _animateAndPop() async {
    await Future.delayed(const Duration(milliseconds: 180));
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _submit() async {
    if (widget.registerMode) {
      if (_firstPin == null) {
        setState(() {
          _firstPin = _pin;
          _pin = '';
          _error = null;
        });
      } else {
        if (_pin == _firstPin) {
          setState(() => _isLoading = true);
          await widget.onRegister?.call(_pin);
          if (!mounted) return;
          await _animateAndPop();
        } else {
          setState(() {
            _error = 'PINs do not match';
            _pin = '';
          });
        }
      }
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final valid = await widget.onVerify!(_pin);
      if (valid) {
        // Reset failed attempts on successful verification
        await AppLockService.resetFailedAttempts();
        if (!mounted) return;
        await _animateAndPop();
      } else {
        // Don't show loading state for failed attempts to prevent flashing
        // Increment failed attempts
        await AppLockService.incrementFailedAttempts(); // Get all the updated state in parallel
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
      ['', '0', '<'],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children:
          keys.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    row.map((key) {
                      if (key == '') {
                        return const SizedBox(width: 70, height: 70);
                      }
                      if (key == '<') {
                        return PinBackspaceButton(onTap: _onBackspace);
                      }
                      return PinKeyButton(
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
    final isRegister = widget.registerMode;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isRegister
              ? (_firstPin == null ? 'Set PIN' : 'Confirm PIN')
              : 'App Locked',
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const SizedBox(height: 32),
                  Icon(
                    isRegister ? Icons.lock_open : Icons.lock_outline,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isRegister
                        ? (_firstPin == null
                            ? 'Enter a new 6-digit PIN'
                            : 'Confirm your new PIN')
                        : 'Enter your PIN',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildPinDots(),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Center(child: _buildKeypad()),
              if (!_isLoading &&
                  widget.allowBiometric &&
                  !widget.registerMode &&
                  !_isInLockdown &&
                  _biometricAttempted) ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.fingerprint, size: 32),
                  label: const Text(
                    'Use Biometrics',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  onPressed: _handleBiometric,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _lockdownTimer?.cancel();
    super.dispose();
  }
}

// PIN Button Widgets
class PinKeyButton extends StatefulWidget {
  final String value;
  final VoidCallback onTap;

  const PinKeyButton({super.key, required this.value, required this.onTap});

  @override
  State<PinKeyButton> createState() => _PinKeyButtonState();
}

class _PinKeyButtonState extends State<PinKeyButton> {
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
            width: 70,
            height: 70,
            child: Center(
              child: Text(
                widget.value,
                style: const TextStyle(
                  fontSize: 28,
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

class PinBackspaceButton extends StatefulWidget {
  final VoidCallback onTap;
  const PinBackspaceButton({super.key, required this.onTap});

  @override
  State<PinBackspaceButton> createState() => _PinBackspaceButtonState();
}

class _PinBackspaceButtonState extends State<PinBackspaceButton> {
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
            width: 70,
            height: 70,
            child: Center(
              child: Icon(
                Icons.backspace_outlined,
                size: 28,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
