import 'package:flutter/material.dart';

class ShinyButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Duration delay;
  final double width;
  final List<Color>? gradientColors1Override;
  final List<Color>? gradientColors2Override;

  const ShinyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.delay = const Duration(milliseconds: 500), // по умолчанию 0.5 сек
    required this.width,
    this.gradientColors1Override,
    this.gradientColors2Override,
  });

  @override
  State<ShinyButton> createState() => _ShinyButtonState();
}

class _ShinyButtonState extends State<ShinyButton>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _hovering = false;

  final List<Color> _defaultGradient1 = [
    const Color.fromARGB(255, 120, 27, 182),
    const Color(0xFF4B1A78),
    const Color(0xFF2E145D),
  ];

  final List<Color> _defaultGradient2 = [
    const Color(0xFF2E145D),
    const Color.fromARGB(255, 64, 2, 188),
    const Color(0xFF4B1A78),
  ];

  // 🔥 Вот тут правильно:
  List<Color> get gradient1 =>
      widget.gradientColors1Override ?? _defaultGradient1;

  List<Color> get gradient2 =>
      widget.gradientColors2Override ?? _defaultGradient2;

  @override
  void initState() {
    super.initState();

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    Future.delayed(widget.delay, () {
      if (mounted) _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedBuilder(
            animation: _gradientController,
            builder: (context, _) {
              return Container(
                width: widget.width,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: List.generate(
                      3,
                      (i) => Color.lerp(
                        gradient1[i],
                        gradient2[i],
                        _gradientController.value,
                      )!,
                    ),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Hover эффект
                    AnimatedOpacity(
                      opacity: _hovering ? 0.1 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    // Текст
                    Center(
                      child: Text(
                        widget.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'PixelFont',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
