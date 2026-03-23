import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class ReminderOverlay extends StatefulWidget {
  final String activityTitle;
  final String category;
  final VoidCallback onDismiss;
  final VoidCallback onMarkDone;

  const ReminderOverlay({
    super.key,
    required this.activityTitle,
    required this.category,
    required this.onDismiss,
    required this.onMarkDone,
  });

  @override
  State<ReminderOverlay> createState() => _ReminderOverlayState();
}

class _ReminderOverlayState extends State<ReminderOverlay>
    with TickerProviderStateMixin {
  late AnimationController _enterCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _glowCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnim = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic),
    );
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _glowAnim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _pulseCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_enterCtrl, _glowCtrl]),
        builder: (_, child) => FadeTransition(
          opacity: _fadeAnim,
          child: Transform.translate(
            offset: Offset(0, _slideAnim.value),
            child: ScaleTransition(scale: _scaleAnim, child: child),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: AnimatedBuilder(
                animation: _glowCtrl,
                builder: (_, child) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D26).withOpacity(0.92),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: AppColors.violetLight.withOpacity(
                        0.2 + _glowAnim.value * 0.3,
                      ),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.violet.withOpacity(
                          _glowAnim.value * 0.4,
                        ),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: child,
                ),
                child: Stack(
                  children: [
                    // Inner shine
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.06),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bell icon
                          AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (_, child) => Transform.scale(
                              scale: _pulseAnim.value,
                              child: child,
                            ),
                            child: AnimatedBuilder(
                              animation: _glowCtrl,
                              builder: (_, child) => Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF9B5DFF),
                                      Color(0xFF3B82F6),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.violet.withOpacity(
                                        0.4 + _glowAnim.value * 0.3,
                                      ),
                                      blurRadius: 28,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.notifications_active_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.violet.withOpacity(0.2),
                                  AppColors.blue.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: AppColors.violetLight.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              'PENGINGAT KEGIATAN',
                              style: GoogleFonts.dmSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.violetLight,
                                letterSpacing: 1.6,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Title
                          Text(
                            widget.activityTitle,
                            style: GoogleFonts.syne(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              height: 1.2,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          // Category + time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.violetLight,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.category,
                                style: GoogleFonts.dmSans(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.bolt_rounded,
                                    color: AppColors.violetLight,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Sekarang',
                                    style: GoogleFonts.dmSans(
                                      color: AppColors.violetLight,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          // Divider gradient
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.glassBorder,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Buttons
                          Row(
                            children: [
                              // Nanti
                              Expanded(
                                child: GestureDetector(
                                  onTap: widget.onDismiss,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.glassBgSm,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: AppColors.glassBorderSm,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.glassBg,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.glassBorderSm,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.schedule_rounded,
                                            color: AppColors.textSecondary,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Nanti',
                                          style: GoogleFonts.dmSans(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Selesai
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  onTap: widget.onMarkDone,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF9B5DFF),
                                          Color(0xFF3B82F6),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.violet.withOpacity(0.45),
                                          blurRadius: 20,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Tandai Selesai',
                                          style: GoogleFonts.dmSans(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showReminderOverlay(
  BuildContext context, {
  required String activityTitle,
  required String category,
  required VoidCallback onDismiss,
  required VoidCallback onMarkDone,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.75),
    builder: (_) => WillPopScope(
      onWillPop: () async => false,
      child: ReminderOverlay(
        activityTitle: activityTitle,
        category: category,
        onDismiss: () {
          Navigator.pop(context);
          onDismiss();
        },
        onMarkDone: () {
          Navigator.pop(context);
          onMarkDone();
        },
      ),
    ),
  );
}
