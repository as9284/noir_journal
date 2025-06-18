import 'package:flutter/material.dart';
import 'pin_key_button.dart';
import 'pin_backspace_button.dart';
import 'package:local_auth/local_auth.dart';

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
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _biometricAttempted = false;
    if (widget.allowBiometric && !widget.registerMode) {
      _isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_biometricAttempted) {
          _biometricAttempted = true;
          _handleBiometric();
        }
      });
    }
  }

  void _onKeyTap(String value) {
    if (_pin.length < 4 && !_isLoading) {
      setState(() {
        _pin += value;
        _error = null;
      });
      if (_pin.length == 4) {
        _submit();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty && !_isLoading) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _error = null;
      });
    }
  }

  Future<void> _handleBiometric() async {
    if (!mounted) return;

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
      setState(() => _isLoading = false);

      if (valid) {
        if (!mounted) return;
        await _animateAndPop();
      } else {
        setState(() {
          _error = 'Incorrect PIN';
          _pin = '';
        });
      }
    }
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
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
                            ? 'Enter a new 4-digit PIN'
                            : 'Confirm your new PIN')
                        : 'Enter your PIN',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildPinDots(),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
              Center(child: _buildKeypad()),
              if (!_isLoading &&
                  widget.allowBiometric &&
                  !widget.registerMode &&
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
}
