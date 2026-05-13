import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_theme.dart';

class CreatorDashboardScreen extends StatelessWidget {
  const CreatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('لوحة المبدع')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overview stats
          Row(
            children: [
              Expanded(child: _StatCard(label: 'مشاهدات', value: '98.4K', icon: Icons.visibility_outlined, color: AppColors.primary)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(label: 'متابعون', value: '12.4K', icon: Icons.people_outline_rounded, color: AppColors.accent)),
            ],
          ).animate().fadeIn(),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(child: _StatCard(label: 'إجمالي اللايكات', value: '42.1K', icon: Icons.favorite_border_rounded, color: AppColors.error)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(label: 'أرباحي', value: '\$124', icon: Icons.attach_money_rounded, color: AppColors.gold)),
            ],
          ).animate(delay: 80.ms).fadeIn(),

          const SizedBox(height: 20),

          // AI suggestions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A1F6E), Color(0xFF1A1040)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.primaryLight, size: 18),
                    const SizedBox(width: 8),
                    const Text('أفكار ذكية لك', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 14),
                ...[
                  'كيف تربح \$50 يومياً من الهاتف فقط',
                  '3 تطبيقات مجانية تغني عن برامج مدفوعة',
                  'تجربتي مع الاستثمار في الذهب الرقمي',
                ].map((idea) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: AppColors.gold, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              idea,
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white),
                            ),
                          ),
                          const Icon(Icons.arrow_back_ios_rounded, color: Colors.white38, size: 14),
                        ],
                      ),
                    )),
              ],
            ),
          ).animate(delay: 160.ms).fadeIn(),

          const SizedBox(height: 16),

          // Best posting times
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('أفضل أوقات النشر', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TimeSlot(time: '8 ص', engagement: 0.6),
                    _TimeSlot(time: '12 ظ', engagement: 0.8),
                    _TimeSlot(time: '6 م', engagement: 1.0, best: true),
                    _TimeSlot(time: '9 م', engagement: 0.7),
                  ],
                ),
              ],
            ),
          ).animate(delay: 240.ms).fadeIn(),

          const SizedBox(height: 16),

          // Top videos
          const Text('أفضل فيديوهاتك', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          ...List.generate(3, (index) => _VideoRow(rank: index + 1)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textHint)),
        ],
      ),
    );
  }
}

class _TimeSlot extends StatelessWidget {
  final String time;
  final double engagement;
  final bool best;

  const _TimeSlot({required this.time, required this.engagement, this.best = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (best)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(6)),
            child: const Text('الأفضل', style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: Colors.black, fontWeight: FontWeight.w700)),
          ),
        if (!best) const SizedBox(height: 18),
        const SizedBox(height: 4),
        Container(
          width: 36,
          height: 60 * engagement,
          decoration: BoxDecoration(
            color: best ? AppColors.accent : AppColors.primary.withOpacity(0.4),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(time, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textHint)),
      ],
    );
  }
}

class _VideoRow extends StatelessWidget {
  final int rank;
  const _VideoRow({required this.rank});

  @override
  Widget build(BuildContext context) {
    final titles = ['كيف تربح من الإنترنت', 'تعلم Flutter في دقيقة', 'أفضل تطبيقات الربح'];
    final views = ['98.4K', '67.2K', '45.1K'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rank == 1 ? AppColors.gold.withOpacity(0.15) : AppColors.bgSurface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$rank', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: rank == 1 ? AppColors.gold : AppColors.textHint)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(titles[rank - 1], style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textPrimary))),
          Text(views[rank - 1], style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textHint)),
        ],
      ),
    );
  }
}
