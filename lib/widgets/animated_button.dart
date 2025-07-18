import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const AnimatedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.electricBlue, AppTheme.neonGreen],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color:
                        AppTheme.electricBlue.withOpacity(_glowAnimation.value),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    // <--- ADDED Expanded HERE
                    child: Text(
                      widget.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center, // <--- ADDED textAlign HERE
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
