import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;

  runApp(
    ProviderScope(
      child: DailyTrackApp(onboardingDone: onboardingDone),
    ),
  );
}

class DailyTrackApp extends StatelessWidget {
  final bool onboardingDone;
  const DailyTrackApp({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DailyTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: onboardingDone ? const MainShell() : const OnboardingScreen(),
    );
  }
}
