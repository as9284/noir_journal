import 'package:flutter/material.dart';

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
