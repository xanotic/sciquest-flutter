import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _textController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBackground,
              AppTheme.secondaryBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Animated Logo
                AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.electricBlue,
                              AppTheme.neonGreen,
                              AppTheme.softPurple,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.electricBlue.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.science,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                // Animated Title
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, 50 * (1 - _textAnimation.value)),
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  AppTheme.electricBlue,
                                  AppTheme.neonGreen,
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'Sciquest',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Text(
                              'STEM Challenge',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppTheme.textSecondary,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),
                // Animated Subtitle
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value,
                      child: const Text(
                        'Explore the wonders of Science,\nTechnology, Engineering & Math',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(),
                // Animated Button
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value,
                      child: AnimatedButton(
                        text: 'Start Your STEM Journey!',
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
