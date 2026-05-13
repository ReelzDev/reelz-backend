import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final onboarded = prefs.getBool('onboarded') ?? false;

    if (token != null) {
      // مسجّل → الفيد مباشرة
      context.go('/feed');
    } else if (!onboarded) {
      // أول مرة → onboarding
      context.go('/onboarding');
    } else {
      // غير مسجّل لكن زار التطبيق من قبل → الفيد بدون تسجيل
      context.go('/feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(26)),
              child: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 52),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut).fadeIn(duration: 400.ms),

            const SizedBox(height: 20),

            Text('Reelz', style: TextStyle(fontFamily: 'Cairo', fontSize: 38, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -1))
                .animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.3, end: 0),

            const SizedBox(height: 8),

            Text('تعلم · اكسب · ارتقِ', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, color: AppColors.textSecondary, letterSpacing: 1))
                .animate().fadeIn(delay: 500.ms, duration: 500.ms),

            const SizedBox(height: 60),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 6, height: 6,
                decoration: BoxDecoration(
                  color: i == 0 ? AppColors.primary : AppColors.textHint,
                  shape: BoxShape.circle,
                ),
              ).animate(delay: Duration(milliseconds: 700 + i * 150)).fadeIn()),
            ),
          ],
        ),
      ),
    );
  }
}
