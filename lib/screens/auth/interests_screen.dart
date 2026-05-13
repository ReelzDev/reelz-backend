import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

class _Interest {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;

  const _Interest({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Set<String> _selected = {};

  final List<_Interest> interests = const [
    _Interest(
      id: 'learn',
      emoji: '📚',
      title: 'تعلم وطور نفسك',
      subtitle: 'مهارات، لغات، تكنولوجيا',
      color: Color(0xFF4F8BFF),
    ),
    _Interest(
      id: 'earn',
      emoji: '💰',
      title: 'اكسب وارتق مالياً',
      subtitle: 'ربح، استثمار، مشاريع',
      color: Color(0xFFFFB800),
    ),
    _Interest(
      id: 'entertain',
      emoji: '🎬',
      title: 'ترفيه وإبداع',
      subtitle: 'محتوى ممتع وملهم',
      color: Color(0xFFFF4D6A),
    ),
    _Interest(
      id: 'local',
      emoji: '🌍',
      title: 'محتوى محلي',
      subtitle: 'من بلدك ولمجتمعك',
      color: Color(0xFF00E5A0),
    ),
    _Interest(
      id: 'business',
      emoji: '🚀',
      title: 'ريادة أعمال',
      subtitle: 'شركات ناشئة وأفكار',
      color: Color(0xFF5B4FE8),
    ),
    _Interest(
      id: 'tech',
      emoji: '💻',
      title: 'تكنولوجيا وبرمجة',
      subtitle: 'AI، تطوير، ابتكار',
      color: Color(0xFF00C2FF),
    ),
  ];

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              Text(
                'ما الذي يهمك؟',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 8),

              Text(
                'اختر اهتماماتك وسنخصص المحتوى لك\nيمكنك اختيار أكثر من واحد',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary, height: 1.6),
              ).animate(delay: 100.ms).fadeIn(),

              const SizedBox(height: 32),

              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: interests.length,
                  itemBuilder: (context, i) {
                    final item = interests[i];
                    final isSelected = _selected.contains(item.id);

                    return GestureDetector(
                      onTap: () => _toggle(item.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? item.color.withOpacity(0.15)
                              : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? item.color : AppColors.bgSurface,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.emoji, style: const TextStyle(fontSize: 30)),
                                if (isSelected)
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: item.color,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                                  ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? item.color : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  item.subtitle,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: Duration(milliseconds: 150 + i * 60)).fadeIn().scale(begin: const Offset(0.9, 0.9));
                  },
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _selected.isEmpty ? null : () => context.go('/feed'),
                child: Text(
                  _selected.isEmpty ? 'اختر اهتماماً على الأقل' : 'ابدأ التصفح  →',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ).animate(delay: 500.ms).fadeIn(),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
