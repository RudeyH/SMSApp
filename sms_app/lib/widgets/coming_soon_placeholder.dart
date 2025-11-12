import 'package:flutter/material.dart';

class ComingSoonPlaceholder extends StatefulWidget {
  final String menuName;
  const ComingSoonPlaceholder({super.key, required this.menuName});

  @override
  State<ComingSoonPlaceholder> createState() => _ComingSoonPlaceholderState();
}

class _ComingSoonPlaceholderState extends State<ComingSoonPlaceholder>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _pulseController;
  late final AnimationController _bounceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Background shimmer
    _fadeController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.05, end: 0.15).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Text pulse
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Bouncing icon
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOutQuad),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[850]! : Colors.grey[200]!;
    final accentColor = isDarkMode ? Colors.grey[700]! : Colors.grey[400]!;
    final shimmerColor = isDarkMode ? Colors.grey[600]! : Colors.white;
    final textColor = isDarkMode ? Colors.grey[200]! : Colors.grey[800]!;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _fadeController,
        _pulseController,
        _bounceController,
      ]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.5, 1.0],
              colors: [
                baseColor.withOpacity(0.8),
                shimmerColor.withOpacity(0.15 + _fadeAnimation.value),
                accentColor.withOpacity(0.7),
              ],
              transform: GradientRotation(_fadeController.value * 3.14),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: Icon(
                    Icons.construction_rounded,
                    size: 60,
                    color: textColor.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${widget.menuName} Section',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Text(
                    'Coming Soon...',
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
