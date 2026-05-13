import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../services/providers.dart';
import '../../services/ad_service.dart';

class RedeemScreen extends ConsumerStatefulWidget {
  const RedeemScreen({super.key});

  @override
  ConsumerState<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends ConsumerState<RedeemScreen> {
  bool _isLoading = false;

  final List<Map<String, dynamic>> rewards = [
    {
      'emoji': '⭐',
      'title': 'اشتراك VIP شهر',
      'desc': 'بدون إعلانات + مميزات حصرية',
      'points': 2000,
      'color': Color(0xFF5B4FE8),
    },
    {
      'emoji': '💳',
      'title': 'رصيد 5\$',
      'desc': 'رصيد قابل للسحب',
      'points': 1000,
      'color': Color(0xFF00E5A0),
    },
    {
      'emoji': '🎁',
      'title': 'بطاقة هدية Amazon',
      'desc': 'بطاقة 10\$ من Amazon',
      'points': 3000,
      'color': Color(0xFFFF9900),
    },
    {
      'emoji': '📱',
      'title': 'شحن رصيد هاتف',
      'desc': 'شحن 5000 دينار',
      'points': 500,
      'color': Color(0xFF4F8BFF),
    },
    {
      'emoji': '🚀',
      'title': 'تعزيز فيديوهاتك',
      'desc': 'ترويج فيديو لمدة 24 ساعة',
      'points': 1500,
      'color': Color(0xFFFF4D6A),
    },
    {
      'emoji': '💰',
      'title': 'ضعف النقاط يوم كامل',
      'desc': 'اكسب ضعف النقاط لمدة يوم',
      'points': 300,
      'color': Color(0xFFFFB800),
    },
  ];

  Future<void> _redeem(Map<String, dynamic> reward, int currentPoints) async {
    if (currentPoints < reward['points']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'تحتاج ${reward['points'] - currentPoints} نقطة إضافية',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }

    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('تأكيد الاستبدال',
            style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(reward['emoji'], style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(reward['title'],
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('سيتم خصم ${reward['points']} نقطة',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary)),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textHint)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('استبدل الآن', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    // TODO: Call API to redeem points
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Text('تم الاستبدال بنجاح! ${reward['emoji']}',
              style: const TextStyle(fontFamily: 'Cairo')),
        ]),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pointsState = ref.watch(pointsProvider);
    final currentPoints = pointsState.totalPoints;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('استبدل نقاطك')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Points header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A1F6E), Color(0xFF0A0A1F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(children: [
                  const Icon(Icons.star_rounded, color: AppColors.gold, size: 36),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('رصيد نقاطك', style: TextStyle(
                        fontFamily: 'Cairo', fontSize: 13, color: Colors.white60)),
                    Text('$currentPoints نقطة', style: const TextStyle(
                        fontFamily: 'Cairo', fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.gold)),
                  ]),
                  const Spacer(),
                  // Watch ad for points
                  RewardedAdButton(
                    onRewarded: (pts) {
                      ref.read(pointsProvider.notifier).addPoints(pts);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('ربحت $pts نقطة! 🎉',
                            style: const TextStyle(fontFamily: 'Cairo')),
                        backgroundColor: AppColors.accent,
                        behavior: SnackBarBehavior.floating,
                      ));
                    },
                  ),
                ]),
              ).animate().fadeIn(),

              const SizedBox(height: 20),

              const Text('اختر مكافأتك', style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),

              const SizedBox(height: 12),

              // Rewards grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: rewards.length,
                itemBuilder: (context, i) {
                  final r = rewards[i];
                  final canRedeem = currentPoints >= r['points'];
                  final color = r['color'] as Color;

                  return GestureDetector(
                    onTap: () => _redeem(r, currentPoints),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: canRedeem ? color.withOpacity(0.1) : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: canRedeem ? color.withOpacity(0.4) : AppColors.bgSurface,
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r['emoji'] as String, style: const TextStyle(fontSize: 32)),
                          const Spacer(),
                          Text(r['title'] as String, style: TextStyle(
                            fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700,
                            color: canRedeem ? color : AppColors.textSecondary,
                          )),
                          const SizedBox(height: 4),
                          Text(r['desc'] as String, style: const TextStyle(
                            fontFamily: 'Cairo', fontSize: 11, color: AppColors.textHint,
                          )),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: canRedeem ? color.withOpacity(0.15) : AppColors.bgSurface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.star_rounded,
                                  color: canRedeem ? color : AppColors.textHint, size: 13),
                              const SizedBox(width: 4),
                              Text('${r['points']}', style: TextStyle(
                                fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700,
                                color: canRedeem ? color : AppColors.textHint,
                              )),
                            ]),
                          ),
                          if (!canRedeem) ...[
                            const SizedBox(height: 6),
                            Text('تحتاج ${(r['points'] as int) - currentPoints} نقطة', style: const TextStyle(
                              fontFamily: 'Cairo', fontSize: 10, color: AppColors.textHint,
                            )),
                          ],
                        ],
                      ),
                    ),
                  ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().scale(begin: const Offset(0.9, 0.9));
                },
              ),

              const SizedBox(height: 24),
            ],
          ),

          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
