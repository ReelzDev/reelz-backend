import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_theme.dart';
import '../../services/providers.dart';

class PointsScreen extends ConsumerStatefulWidget {
  const PointsScreen({super.key});

  @override
  ConsumerState<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends ConsumerState<PointsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(pointsProvider.notifier).load());
  }

  String _reasonLabel(String reason) {
    const map = {
      'watch_video': '🎬 مشاهدة فيديو',
      'like': '❤️ إعجاب',
      'comment': '💬 تعليق',
      'share': '🔁 مشاركة',
      'daily_login': '🌟 دخول يومي',
      'upload_video': '🚀 رفع فيديو',
      'get_followed': '👥 متابع جديد',
    };
    return map[reason] ?? reason;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pointsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('نقاطي ومكافآتي')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Points hero ──────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A1F6E), Color(0xFF0A0A1F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(children: [
                    const Icon(Icons.star_rounded, color: AppColors.gold, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      '${state.totalPoints}',
                      style: const TextStyle(
                        fontFamily: 'Cairo', fontSize: 48,
                        fontWeight: FontWeight.w800, color: AppColors.gold,
                      ),
                    ),
                    const Text('نقطة إجمالية',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.white60)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '🔥 ${state.weeklyPoints} نقطة هذا الأسبوع',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white70),
                      ),
                    ),
                  ]),
                ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),

                const SizedBox(height: 16),

                // ── Redeem options ───────────────────────────
                const Text('استبدل نقاطك', style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _RedeemCard(
                    emoji: '💳', label: 'رصيد', points: 500,
                    currentPoints: state.totalPoints, onTap: () {},
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _RedeemCard(
                    emoji: '🎁', label: 'هدية', points: 1000,
                    currentPoints: state.totalPoints, onTap: () {},
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _RedeemCard(
                    emoji: '⭐', label: 'VIP', points: 2000,
                    currentPoints: state.totalPoints, onTap: () {},
                  )),
                ]).animate(delay: 100.ms).fadeIn(),

                const SizedBox(height: 20),

                // ── How to earn ──────────────────────────────
                const Text('كيف تكسب نقاط؟', style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                ...[
                  ('🎬', 'مشاهدة فيديو كاملاً', '+5'),
                  ('❤️', 'الإعجاب بفيديو', '+2'),
                  ('💬', 'كتابة تعليق', '+3'),
                  ('🌟', 'تسجيل الدخول يومياً', '+10'),
                  ('🚀', 'رفع فيديو', '+20'),
                ].map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Text(e.$1, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(e.$2,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textPrimary))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(e.$3,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold)),
                    ),
                  ]),
                )).toList().animate(interval: 50.ms).fadeIn().slideX(begin: 0.1),

                const SizedBox(height: 20),

                // ── History ──────────────────────────────────
                if (state.history.isNotEmpty) ...[
                  const Text('سجل النقاط', style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  ...state.history.take(15).map((tx) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Expanded(child: Text(_reasonLabel(tx.reason),
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary))),
                      Text('+${tx.points}',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accent)),
                    ]),
                  )).toList(),
                ],

                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class _RedeemCard extends StatelessWidget {
  final String emoji;
  final String label;
  final int points;
  final int currentPoints;
  final VoidCallback onTap;

  const _RedeemCard({
    required this.emoji, required this.label,
    required this.points, required this.currentPoints, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canRedeem = currentPoints >= points;
    return GestureDetector(
      onTap: canRedeem ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: canRedeem ? AppColors.gold.withOpacity(0.1) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: canRedeem ? AppColors.gold.withOpacity(0.4) : Colors.transparent),
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(
            fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600,
            color: canRedeem ? AppColors.gold : AppColors.textHint)),
          Text('$points نقطة', style: TextStyle(
            fontFamily: 'Cairo', fontSize: 10,
            color: canRedeem ? AppColors.gold.withOpacity(0.7) : AppColors.textHint)),
        ]),
      ),
    );
  }
}
