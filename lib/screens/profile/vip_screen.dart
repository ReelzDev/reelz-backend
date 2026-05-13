import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

class VipScreen extends StatefulWidget {
  const VipScreen({super.key});
  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> {
  int _selectedPlan = 1; // 0=monthly, 1=yearly

  final plans = [
    {'label': 'شهري', 'price': '\$4.99', 'per': 'شهر', 'savings': null},
    {'label': 'سنوي', 'price': '\$29.99', 'per': 'سنة', 'savings': 'وفّر 40%'},
  ];

  final features = [
    ('🚫', 'بدون إعلانات نهائياً'),
    ('⚡', 'وضع الفائدة المتقدم'),
    ('📊', 'تحليلات المبدع الكاملة'),
    ('🎯', 'أولوية في الخوارزمية'),
    ('💎', 'شارة VIP على ملفك'),
    ('🎁', 'ضعف نقاط المكافآت'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Reelz VIP'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [

          // Hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5B4FE8), Color(0xFF3B2FC8)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(children: [
              const Text('💎', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              const Text('Reelz VIP', style: TextStyle(
                fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 8),
              const Text('تجربة بلا حدود — محتوى، ربح، ونمو',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center),
            ]),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 24),

          // Plan selector
          Row(children: List.generate(plans.length, (i) {
            final plan = plans[i];
            final active = _selectedPlan == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPlan = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(left: i > 0 ? 10 : 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary.withOpacity(0.15) : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: active ? AppColors.primary : Colors.transparent, width: 2),
                  ),
                  child: Column(children: [
                    if (plan['savings'] != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
                        child: Text(plan['savings']!,
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black)),
                      )
                    else
                      const SizedBox(height: 22),
                    Text(plan['label']!, style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600,
                      color: active ? AppColors.primaryLight : AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(plan['price']!, style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w800,
                      color: active ? Colors.white : AppColors.textPrimary)),
                    Text('/ ${plan['per']}', style: const TextStyle(
                      fontFamily: 'Cairo', fontSize: 11, color: AppColors.textHint)),
                  ]),
                ),
              ),
            );
          })).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 24),

          // Features
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ما تحصل عليه:', style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 14),
                ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    Text(f.$1, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text(f.$2, style: const TextStyle(
                      fontFamily: 'Cairo', fontSize: 14, color: AppColors.textPrimary)),
                    const Spacer(),
                    const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 18),
                  ]),
                )),
              ],
            ),
          ).animate(delay: 150.ms).fadeIn(),

          const SizedBox(height: 24),

          // Subscribe button
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              'اشترك الآن — ${plans[_selectedPlan]['price']}/${plans[_selectedPlan]['per']}',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ).animate(delay: 200.ms).fadeIn(),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ليس الآن', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textHint)),
          ),

          const SizedBox(height: 8),
          const Text('يمكن الإلغاء في أي وقت • لا رسوم خفية',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textHint),
            textAlign: TextAlign.center),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}
