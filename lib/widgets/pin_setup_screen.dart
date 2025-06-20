import 'package:flutter/material.dart';

class PinSetupScreen extends StatefulWidget {
  final Future<void> Function(String pin)? onRegister;

  const PinSetupScreen({super.key, this.onRegister});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin = '';
  String? _error;
  bool _isLoading = false;
  String? _firstPin;

  void _onKeyTap(String value) {
    if (_pin.length < 6 && !_isLoading) {
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
    if (_pin.isNotEmpty && !_isLoading) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _error = null;
      });
    }
  }

  Future<void> _submit() async {
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
  }

  Future<void> _animateAndPop() async {
    await Future.delayed(const Duration(milliseconds: 180));
    if (mounted) Navigator.of(context).pop(true);
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
                        return _PinBackspaceButton(onTap: _onBackspace);
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_firstPin == null ? 'Set PIN' : 'Confirm PIN'),
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
                    Icons.lock_open,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _firstPin == null
                        ? 'Enter a new 6-digit PIN'
                        : 'Confirm your new PIN',
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
            ],
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
