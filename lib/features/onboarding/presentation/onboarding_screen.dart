import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.track_changes_rounded,
      iconColor: AppColors.violetLight,
      title: 'Selamat Datang\ndi DailyTrack',
      subtitle: 'Personal Productivity OS kamu.\nCatat, kelola, dan capai semua targetmu.',
      tag: 'v3.0 Glassmorphism Edition',
    ),
    _OnboardingPage(
      icon: Icons.notifications_active_rounded,
      iconColor: AppColors.cyanLight,
      title: 'Aktifkan\nNotifikasi',
      subtitle: 'DailyTrack butuh izin notifikasi untuk mengingatkan kamu tepat waktu.',
      tag: 'LANGKAH 1',
      isPermission: true,
      permissionType: 'notification',
    ),
    _OnboardingPage(
      icon: Icons.battery_charging_full_rounded,
      iconColor: AppColors.amberLight,
      title: 'Izinkan\nBackground Activity',
      subtitle: 'Agar alarm tetap jalan meski app ditutup.\nWajib untuk notifikasi ontime.',
      tag: 'LANGKAH 2',
      isPermission: true,
      permissionType: 'battery',
    ),
    _OnboardingPage(
      icon: Icons.push_pin_rounded,
      iconColor: AppColors.green,
      title: 'Lock App di\nRecent Apps',
      subtitle: 'Tap & tahan icon DailyTrack di Recent Apps lalu pilih Lock.',
      tag: 'LANGKAH 3',
      isPermission: false,
      permissionType: 'lock',
    ),
    _OnboardingPage(
      icon: Icons.rocket_launch_rounded,
      iconColor: AppColors.violetLight,
      title: 'Semua Siap!\nAyo Mulai',
      subtitle: 'DailyTrack siap menemani hari-harimu.\nTambahkan kegiatan pertamamu sekarang!',
      tag: 'SELESAI',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeCtrl);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _skip() {
    HapticFeedback.lightImpact();
    _finish();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  Future<void> _handlePermission(String type) async {
    HapticFeedback.mediumImpact();
    const channel = MethodChannel('id.dailytrack.fresh/notification');
    try {
      if (type == 'notification') {
        await channel.invokeMethod('requestNotificationPermission');
      } else if (type == 'battery') {
        await channel.invokeMethod('requestBatteryOptimization');
      }
    } catch (_) {}
    _next();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const AuroraBackground(),
          FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _pages.length,
                    itemBuilder: (_, i) => _PageContent(
                      page: _pages[i],
                      onPermission: _handlePermission,
                      onNext: _next,
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _currentPage == i ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: _currentPage == i
                                    ? AppColors.violetLight
                                    : AppColors.glassBorderSm,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!_pages[_currentPage].isPermission)
                          GestureDetector(
                            onTap: _next,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.violet, AppColors.blue],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.violet.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Text(
                                _currentPage == _pages.length - 1
                                    ? 'Mulai Sekarang!'
                                    : 'Lanjut',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.syne(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        if (_currentPage < _pages.length - 1) ...[
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _skip,
                            child: Text(
                              'Lewati',
                              style: GoogleFonts.dmSans(
                                color: AppColors.textTertiary,
                                fontSize: 13,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;
  final Function(String) onPermission;
  final VoidCallback onNext;

  const _PageContent({
    required this.page,
    required this.onPermission,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: page.iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: page.iconColor.withOpacity(0.3)),
            ),
            child: Text(
              page.tag,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: page.iconColor,
                letterSpacing: 1.4,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(height: 40),
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: page.iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: page.iconColor.withOpacity(0.25)),
                ),
                child: Icon(page.icon, color: page.iconColor, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: GoogleFonts.syne(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1.0,
              height: 1.1,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.7,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 32),
          if (page.isPermission)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.glassBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.glassBorderSm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: page.iconColor, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Mengapa ini penting?',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: page.iconColor,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        page.permissionType == 'battery'
                            ? 'OPPO/ColorOS agresif mematikan app di background. Tanpa izin ini, alarm bisa delay atau tidak muncul.'
                            : 'Tanpa izin notifikasi, DailyTrack tidak bisa mengingatkan kamu.',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.6,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => onPermission(page.permissionType),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                page.iconColor.withOpacity(0.8),
                                page.iconColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: page.iconColor.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            page.permissionType == 'battery'
                                ? 'Izinkan Background Activity'
                                : 'Izinkan Notifikasi',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (page.permissionType == 'lock')
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.glassBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.glassBorderSm),
                  ),
                  child: Column(
                    children: [
                      _StepGuide(
                        step: '1',
                        text: 'Swipe ke Recent Apps',
                        color: AppColors.green,
                      ),
                      const SizedBox(height: 12),
                      _StepGuide(
                        step: '2',
                        text: 'Cari app DailyTrack',
                        color: AppColors.green,
                      ),
                      const SizedBox(height: 12),
                      _StepGuide(
                        step: '3',
                        text: 'Tap & tahan → pilih Lock',
                        color: AppColors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepGuide extends StatelessWidget {
  final String step;
  final String text;
  final Color color;

  const _StepGuide({
    required this.step,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              step,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.dmSans(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String tag;
  final bool isPermission;
  final String permissionType;

  const _OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.tag,
    this.isPermission = false,
    this.permissionType = '',
  });
}
