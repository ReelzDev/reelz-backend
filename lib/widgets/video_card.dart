import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../models/models.dart';

class VideoCard extends StatefulWidget {
  final VideoModel video;
  final bool isActive;

  const VideoCard({super.key, required this.video, required this.isActive});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  bool _isLiked = false;
  bool _isSaved = false;
  int _likes = 0;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.video.isLiked;
    _isSaved = widget.video.isSaved;
    _likes = widget.video.likesCount;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likes += _isLiked ? 1 : -1;
    });
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  Color get _categoryColor {
    switch (widget.video.category) {
      case VideoCategory.learn:
        return AppColors.tagLearn;
      case VideoCategory.earn:
        return AppColors.gold;
      case VideoCategory.entertain:
        return AppColors.tagEntertain;
      case VideoCategory.local:
        return AppColors.accent;
    }
  }

  String get _categoryLabel {
    switch (widget.video.category) {
      case VideoCategory.learn:
        return 'تعليمي';
      case VideoCategory.earn:
        return 'ربحي';
      case VideoCategory.entertain:
        return 'ترفيهي';
      case VideoCategory.local:
        return 'محلي';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video background (thumbnail for now)
        CachedNetworkImage(
          imageUrl: widget.video.thumbnailUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: AppColors.bgCard),
          errorWidget: (_, __, ___) => Container(
            color: AppColors.bgCard,
            child: const Icon(Icons.videocam_off, color: AppColors.textHint, size: 48),
          ),
        ),

        // Gradient overlay
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                Color(0x44000000),
                Color(0xCC000000),
              ],
              stops: [0, 0.4, 0.7, 1],
            ),
          ),
        ),

        // Right action buttons
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            children: [
              _ActionBtn(
                icon: _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                label: _formatCount(_likes),
                color: _isLiked ? AppColors.error : Colors.white,
                onTap: _toggleLike,
              ),
              const SizedBox(height: 20),
              _ActionBtn(
                icon: Icons.chat_bubble_outline_rounded,
                label: _formatCount(widget.video.commentsCount),
                onTap: () => context.push('/comments/${widget.video.id}'),
              ),
              const SizedBox(height: 20),
              _ActionBtn(
                icon: Icons.share_outlined,
                label: _formatCount(widget.video.sharesCount),
                onTap: () {},
              ),
              const SizedBox(height: 20),
              _ActionBtn(
                icon: _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                label: _isSaved ? 'محفوظ' : 'احفظ',
                color: _isSaved ? AppColors.gold : Colors.white,
                onTap: () => setState(() => _isSaved = !_isSaved),
              ),
              const SizedBox(height: 20),
              // Creator avatar
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: AppColors.primary,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
            ],
          ),
        ),

        // Bottom info
        Positioned(
          left: 16,
          right: 80,
          bottom: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _categoryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _categoryColor.withOpacity(0.5)),
                ),
                child: Text(
                  _categoryLabel,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _categoryColor,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Creator name
              Row(
                children: [
                  Text(
                    '@${widget.video.creator.username}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (widget.video.creator.isVerified)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.verified_rounded, color: AppColors.primary, size: 14),
                    ),
                ],
              ),

              const SizedBox(height: 6),

              // Title
              Text(
                widget.video.title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              Text(
                widget.video.description,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.75),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Product link
              if (widget.video.productLink != null) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_bag_outlined, color: Colors.black, size: 15),
                        SizedBox(width: 6),
                        Text(
                          'اشترِ الآن',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Points earned indicator (shown briefly)
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedOpacity(
              opacity: widget.isActive ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.accent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '+5 نقاط',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    this.color = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
            ),
          ),
        ],
      ),
    );
  }
}
