import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noir_journal/screens/home.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  bool _showNamePrompt = false;
  final TextEditingController _nameController = TextEditingController();
  bool _nameError = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _completeIntro(String? name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('intro_seen', true);
    if (name != null && name.trim().isNotEmpty) {
      await prefs.setString('user_name', name.trim());
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder:
            (context, animation, secondaryAnimation) => const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          );
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _onGetStarted() {
    setState(() => _showNamePrompt = true);
    _slideController.forward(from: 0);
  }

  void _onNameSubmit() {
    final name = _nameController.text.trim();
    setState(() => _nameError = name.isEmpty);
    if (name.isNotEmpty) {
      _completeIntro(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child:
                      !_showNamePrompt
                          ? _IntroContent(
                            isDark: isDark,
                            onGetStarted: _onGetStarted,
                          )
                          : const SizedBox.shrink(),
                ),
                if (_showNamePrompt)
                  SlideTransition(
                    position: _slideAnimation,
                    child: _NamePrompt(
                      isDark: isDark,
                      nameController: _nameController,
                      nameError: _nameError,
                      onNameSubmit: _onNameSubmit,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroContent extends StatelessWidget {
  final bool isDark;
  final VoidCallback onGetStarted;
  const _IntroContent({required this.isDark, required this.onGetStarted});
  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('intro'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.elasticOut,
          builder:
              (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white10 : Colors.black12,
            ),
            child: Icon(
              Icons.emoji_nature,
              size: 64,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Welcome to Noir Journal',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Capture your thoughts, memories, and ideas in a beautiful, private journal.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 400),
          child: SizedBox(
            width: 220,
            child: FilledButton(
              onPressed: onGetStarted,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
                backgroundColor: isDark ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                foregroundColor: isDark ? Colors.black : Colors.white,
                elevation: 1,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Get Started'),
            ),
          ),
        ),
      ],
    );
  }
}

class _NamePrompt extends StatelessWidget {
  final bool isDark;
  final TextEditingController nameController;
  final bool nameError;
  final VoidCallback onNameSubmit;
  const _NamePrompt({
    required this.isDark,
    required this.nameController,
    required this.nameError,
    required this.onNameSubmit,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('namePrompt'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'What is your name?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: nameController,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            labelText: 'Your Name',
            labelStyle: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            errorText: nameError ? 'Please enter your name' : null,
            errorStyle: const TextStyle(color: Colors.redAccent),
            filled: true,
            fillColor: isDark ? Colors.white10 : Colors.black12,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white24 : Colors.black26,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          cursorColor: isDark ? Colors.white : Colors.black,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onNameSubmit(),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onNameSubmit,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: isDark ? Colors.white : Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            foregroundColor: isDark ? Colors.black : Colors.white,
            elevation: 4,
          ),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
