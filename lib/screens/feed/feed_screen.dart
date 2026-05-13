import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/video_card.dart';
import '../../widgets/focus_mode_banner.dart';

final focusModeProvider = StateProvider<bool>((ref) => false);
final feedModeProvider = StateProvider<VideoCategory?>((ref) => null);

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Mock data — replace with API call
  final List<VideoModel> _videos = _mockVideos();

  @override
  Widget build(BuildContext context) {
    final focusMode = ref.watch(focusModeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video feed
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: _videos.length,
            itemBuilder: (context, i) {
              return VideoCard(
                video: _videos[i],
                isActive: i == _currentIndex,
              );
            },
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // App name
                  Text(
                    'Reelz',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),

                  const Spacer(),

                  // Feed filter tabs
                  _FeedTab(label: 'لك', active: true, onTap: () {}),
                  const SizedBox(width: 8),
                  _FeedTab(label: 'محلي', active: false, onTap: () {}),

                  const Spacer(),

                  // Focus mode toggle
                  GestureDetector(
                    onTap: () => ref.read(focusModeProvider.notifier).state = !focusMode,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: focusMode
                            ? AppColors.accent.withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: focusMode ? AppColors.accent : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            color: focusMode ? AppColors.accent : Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'فائدة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: focusMode ? AppColors.accent : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Focus mode banner
          if (focusMode)
            const Positioned(
              top: 90,
              left: 0,
              right: 0,
              child: FocusModeBanner(),
            ),
        ],
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FeedTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? Colors.white : Colors.white60,
            ),
          ),
          if (active)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 20,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}

List<VideoModel> _mockVideos() {
  final creator = UserModel(
    id: '1',
    username: 'ahmed_iraq',
    displayName: 'أحمد العراقي',
    country: 'IQ',
    isVerified: true,
    isCreator: true,
  );

  return [
    VideoModel(
      id: '1',
      userId: '1',
      creator: creator,
      videoUrl: 'https://example.com/video1.m3u8',
      thumbnailUrl: 'https://picsum.photos/400/700?random=1',
      title: 'كيف تربح 50\$ يومياً من الإنترنت',
      description: 'طريقة مجربة وفعّالة تناسب الجميع',
      category: VideoCategory.earn,
      type: VideoType.profitable,
      likesCount: 12400,
      commentsCount: 340,
      sharesCount: 890,
      viewsCount: 98000,
      duration: const Duration(seconds: 45),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      country: 'IQ',
    ),
    VideoModel(
      id: '2',
      userId: '1',
      creator: creator,
      videoUrl: 'https://example.com/video2.m3u8',
      thumbnailUrl: 'https://picsum.photos/400/700?random=2',
      title: 'تعلم Flutter في 60 ثانية',
      description: 'مقدمة سريعة لأقوى إطار عمل للموبايل',
      category: VideoCategory.learn,
      type: VideoType.educational,
      likesCount: 8200,
      commentsCount: 210,
      sharesCount: 450,
      viewsCount: 67000,
      duration: const Duration(seconds: 60),
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      country: 'IQ',
    ),
  ];
}
