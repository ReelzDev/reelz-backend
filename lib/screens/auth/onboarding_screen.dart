import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';

class _OnboardSlide {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;

  const _OnboardSlide({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accent,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  final List<_OnboardSlide> slides = const [
    _OnboardSlide(
      emoji: '🎯',
      title: 'محتوى يخدم هدفك',
      subtitle: 'اختر ما تريد — تعلم، ترفيه، أو فرص ربح\nوالتطبيق يتكيف معك من اللحظة الأولى',
      accent: Color(0xFF5B4FE8),
    ),
    _OnboardSlide(
      emoji: '💰',
      title: 'اكسب وأنت تشاهد',
      subtitle: 'نقاط حقيقية على كل مشاهدة وتفاعل\nحوّلها إلى رصيد وخصومات وخدمات',
      accent: Color(0xFFFFB800),
    ),
    _OnboardSlide(
      emoji: '🚀',
      title: 'صانع محتوى ذكي',
      subtitle: 'أفكار جاهزة، تحليل أداء، ووقت نشر مثالي\nكل ما تحتاجه لتنمو بسرعة',
      accent: Color(0xFF00E5A0),
    ),
  ];

  void _next() {
    if (_current < slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'تخطي',
                  style: TextStyle(color: AppColors.textHint, fontFamily: 'Cairo'),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _current = i),
                itemCount: slides.length,
                itemBuilder: (context, i) {
                  final slide = slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Emoji circle
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: slide.accent.withOpacity(0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: slide.accent.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              slide.emoji,
                              style: const TextStyle(fontSize: 54),
                            ),
                          ),
                        )
                            .animate(key: ValueKey('emoji_$i'))
                            .scale(duration: 500.ms, curve: Curves.elasticOut),

                        const SizedBox(height: 40),

                        Text(
                          slide.title,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate(key: ValueKey('title_$i'))
                            .fadeIn(delay: 150.ms)
                            .slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 16),

                        Text(
                          slide.subtitle,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            height: 1.8,
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate(key: ValueKey('sub_$i'))
                            .fadeIn(delay: 250.ms),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (i) {
                final isActive = i == _current;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.textHint,
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: slides[_current].accent,
                ),
                child: Text(
                  _current == slides.length - 1 ? 'ابدأ الآن' : 'التالي',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
