import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AdService {
  static Future<void> initialize() async {}

  static int _count = 0;
  static void onVideoSwiped() => _count++;
  static bool shouldShowAd() => _count > 0 && _count % 5 == 0;
}

class VideoAdCard extends StatelessWidget {
  final VoidCallback onSkip;
  const VideoAdCard({super.key, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(fit: StackFit.expand, children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            ),
          ),
        ),
        Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gold.withOpacity(0.5)),
            ),
            child: const Text('إعلان', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 24),
          const Icon(Icons.campaign_outlined, color: Colors.white54, size: 80),
          const SizedBox(height: 16),
          const Text('إعلانك هنا', style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('تواصل معنا لنشر إعلانك\nوصل لآلاف المستخدمين',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.white60, height: 1.6),
            textAlign: TextAlign.center),
        ])),
        Positioned(
          top: 60, left: 16,
          child: GestureDetector(
            onTap: onSkip,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Text('تخطي', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white)),
                SizedBox(width: 4),
                Icon(Icons.skip_next, color: Colors.white, size: 16),
              ]),
            ),
          ),
        ),
        Positioned(bottom: 100, left: 16, right: 16, child: _AdCountdown(onFinish: onSkip)),
      ]),
    );
  }
}

class _AdCountdown extends StatefulWidget {
  final VoidCallback onFinish;
  const _AdCountdown({required this.onFinish});
  @override
  State<_AdCountdown> createState() => _AdCountdownState();
}

class _AdCountdownState extends State<_AdCountdown> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..forward()
      ..addStatusListener((s) { if (s == AnimationStatus.completed) widget.onFinish(); });
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Column(children: [
      Text('${(5 - _c.value * 5).ceil()} ثوانٍ', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white60)),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(value: _c.value, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(AppColors.gold), minHeight: 3),
      ),
    ]),
  );
}

class WatchAdForPointsButton extends StatelessWidget {
  final Function(int) onRewarded;
  const WatchAdForPointsButton({super.key, required this.onRewarded});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onRewarded(50),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFFF8C00)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.play_circle_outline, color: Colors.black, size: 18),
        SizedBox(width: 6),
        Text('شاهد إعلاناً واكسب 50 نقطة', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black)),
      ]),
    ),
  );
}
