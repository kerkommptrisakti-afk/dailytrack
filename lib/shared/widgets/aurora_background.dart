import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _xAnims;
  late final List<Animation<double>> _yAnims;
  late final List<Animation<double>> _scaleAnims;

  final _colors = [
    AppColors.violet,
    AppColors.blue,
    AppColors.cyan,
    AppColors.pink,
    AppColors.amber,
  ];
  final _sizes = [700.0, 600.0, 500.0, 450.0, 350.0];
  final _opacities = [0.5, 0.5, 0.5, 0.5, 0.3];
  final _durations = [18, 22, 20, 24, 16];

  @override
  void initState() {
    super.initState();
    final rng = math.Random(42);
    _controllers = List.generate(
      5,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(seconds: _durations[i]),
      )..repeat(reverse: true),
    );
    _xAnims = List.generate(
      5,
      (i) => Tween<double>(
        begin: -20.0 + rng.nextDouble() * 10,
        end: 20.0 + rng.nextDouble() * 20,
      ).animate(CurvedAnimation(
        parent: _controllers[i],
        curve: Curves.easeInOut,
      )),
    );
    _yAnims = List.generate(
      5,
      (i) => Tween<double>(
        begin: -30.0,
        end: 25.0 + rng.nextDouble() * 15,
      ).animate(CurvedAnimation(
        parent: _controllers[i],
        curve: Curves.easeInOut,
      )),
    );
    _scaleAnims = List.generate(
      5,
      (i) => Tween<double>(
        begin: 0.95,
        end: 1.08,
      ).animate(CurvedAnimation(
        parent: _controllers[i],
        curve: Curves.easeInOut,
      )),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return RepaintBoundary(
      child: Container(
        color: AppColors.bg,
        child: Stack(
          children: List.generate(5, (i) {
            return AnimatedBuilder(
              animation: _controllers[i],
              builder: (_, __) {
                return Positioned(
                  top: (size.height * 0.1 * i) + _yAnims[i].value,
                  left: (size.width * 0.1 * i) + _xAnims[i].value,
                  child: Transform.scale(
                    scale: _scaleAnims[i].value,
                    child: Container(
                      width: _sizes[i],
                      height: _sizes[i],
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _colors[i].withOpacity(_opacities[i]),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.7],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
