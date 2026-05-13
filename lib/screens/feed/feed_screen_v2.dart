import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../services/providers.dart';
import '../../services/video_player_service.dart';
import '../../widgets/video_card.dart';
import '../../widgets/focus_mode_banner.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _focusMode = false;

  @override
  void initState() {
    super.initState();
    // Load feed on start
    Future.microtask(() => ref.read(feedProvider.notifier).loadFeed());
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);

    final feed = ref.read(feedProvider);
    // Load more when near end
    if (index >= feed.videos.length - 3) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  void _toggleFocusMode() {
    setState(() => _focusMode = !_focusMode);
    ref.read(feedProvider.notifier).loadFeed(
      refresh: true,
      focusMode: !_focusMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Video Feed ──────────────────────────────────────
          if (feedState.isLoading && feedState.videos.isEmpty)
            const Center(child: CircularProgressIndicator(color: AppColors.primary))
          else if (feedState.videos.isEmpty)
            _EmptyFeed(onRefresh: () => ref.read(feedProvider.notifier).loadFeed(refresh: true))
          else
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: _onPageChanged,
              itemCount: feedState.videos.length + (feedState.hasMore ? 1 : 0),
              itemBuilder: (context, i) {
                // Loading indicator at end
                if (i == feedState.videos.length) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final video = feedState.videos[i];
                return ReelzVideoPlayer(
                  videoUrl: video.videoUrl,
                  videoId: video.id,
                  isActive: i == _currentIndex,
                  overlay: VideoCard(
                    video: video,
                    isActive: i == _currentIndex,
                    onLike: () {
                      ref.read(feedProvider.notifier).toggleLikeLocally(video.id);
                    },
                  ),
                );
              },
            ),

          // ── Top Bar ─────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Reelz',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  _FeedTab(label: 'لك', active: true, onTap: () {}),
                  const SizedBox(width: 8),
                  _FeedTab(
                    label: 'محلي',
                    active: false,
                    onTap: () => ref.read(feedProvider.notifier).loadFeed(
                      refresh: true,
                      category: 'local',
                    ),
                  ),
                  const Spacer(),
                  // Focus mode toggle
                  GestureDetector(
                    onTap: _toggleFocusMode,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _focusMode
                            ? AppColors.accent.withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _focusMode ? AppColors.accent : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            color: _focusMode ? AppColors.accent : Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'فائدة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _focusMode ? AppColors.accent : Colors.white,
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
          if (_focusMode)
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

class _EmptyFeed extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyFeed({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.video_library_outlined, color: AppColors.textHint, size: 64),
          const SizedBox(height: 16),
          const Text(
            'لا توجد فيديوهات حالياً',
            style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRefresh,
            child: const Text('تحديث', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}
