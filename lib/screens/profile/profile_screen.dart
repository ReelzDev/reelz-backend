import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          // App bar with cover
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.bgDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2A1F6E), Color(0xFF0A0A1F)],
                      ),
                    ),
                  ),
                  // Avatar
                  Positioned(
                    bottom: 16,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 2.5),
                            color: AppColors.bgSurface,
                          ),
                          child: const Icon(Icons.person, color: AppColors.textHint, size: 36),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'أحمد العراقي',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        Text(
                          '@ahmed_iraq',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/profile/edit'),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(label: 'فيديوهات', value: '24'),
                        _Divider(),
                        _StatItem(label: 'متابعون', value: '12.4K'),
                        _Divider(),
                        _StatItem(label: 'يتابعهم', value: '340'),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 12),

                  // Points card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.gold, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('نقاطي', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
                              Text(
                                '4,250 نقطة',
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.gold),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('استبدل', style: TextStyle(fontFamily: 'Cairo', color: AppColors.gold, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 20),

                  // Videos grid placeholder
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                      childAspectRatio: 0.6,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, i) {
                      return Container(
                        color: AppColors.bgSurface,
                        child: Center(
                          child: Icon(Icons.play_circle_outline, color: AppColors.textHint.withOpacity(0.5), size: 28),
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppColors.bgSurface);
  }
}
