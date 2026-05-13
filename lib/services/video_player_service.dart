import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/api_service.dart';

class VideoPlayerService {
  VideoPlayerController? _controller;
  String? _currentVideoId;
  DateTime? _watchStartTime;
  bool _viewRecorded = false;

  VideoPlayerController? get controller => _controller;
  bool get isPlaying => _controller?.value.isPlaying ?? false;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> loadVideo(String videoUrl, String videoId) async {
    // Don't reload same video
    if (_currentVideoId == videoId && _controller != null) return;

    await dispose();

    _currentVideoId = videoId;
    _viewRecorded = false;
    _watchStartTime = DateTime.now();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
    );

    await _controller!.initialize();
    _controller!.setLooping(true);
    _controller!.play();

    // Record view after 3 seconds of watching
    _controller!.addListener(_onPlayerUpdate);
  }

  void _onPlayerUpdate() {
    if (_controller == null || _viewRecorded) return;

    final position = _controller!.value.position;
    final duration = _controller!.value.duration;

    // Record view after watching 3+ seconds
    if (position.inSeconds >= 3 && !_viewRecorded) {
      _viewRecorded = true;
      final completed = duration.inSeconds > 0 &&
          position.inSeconds >= duration.inSeconds * 0.8;

      ApiService.recordView(
        _currentVideoId!,
        watchedSeconds: position.inSeconds,
        completed: completed,
      );
    }
  }

  void play() => _controller?.play();
  void pause() => _controller?.pause();
  void togglePlayPause() {
    if (_controller?.value.isPlaying ?? false) {
      _controller?.pause();
    } else {
      _controller?.play();
    }
  }

  void setVolume(double volume) => _controller?.setVolume(volume);

  Future<void> dispose() async {
    _controller?.removeListener(_onPlayerUpdate);
    await _controller?.dispose();
    _controller = null;
    _currentVideoId = null;
  }
}

// ── Video Player Widget ───────────────────────────────────────
class ReelzVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String videoId;
  final bool isActive;
  final Widget overlay;

  const ReelzVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.videoId,
    required this.isActive,
    required this.overlay,
  });

  @override
  State<ReelzVideoPlayer> createState() => _ReelzVideoPlayerState();
}

class _ReelzVideoPlayerState extends State<ReelzVideoPlayer> {
  final VideoPlayerService _service = VideoPlayerService();
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _initVideo();
  }

  @override
  void didUpdateWidget(ReelzVideoPlayer old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _initVideo();
    } else if (!widget.isActive && old.isActive) {
      _service.pause();
    }
  }

  Future<void> _initVideo() async {
    await _service.loadVideo(widget.videoUrl, widget.videoId);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _service.togglePlayPause();
        setState(() => _showControls = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showControls = false);
        });
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video
          if (_service.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _service.controller!.value.size.width,
                height: _service.controller!.value.size.height,
                child: VideoPlayer(_service.controller!),
              ),
            )
          else
            Container(color: Colors.black),

          // Play/Pause indicator
          if (_showControls)
            Center(
              child: AnimatedOpacity(
                opacity: _showControls ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _service.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),

          // Progress bar at bottom
          if (_service.isInitialized)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _service.controller!,
                allowScrubbing: false,
                colors: const VideoProgressColors(
                  playedColor: Colors.white,
                  bufferedColor: Colors.white30,
                  backgroundColor: Colors.transparent,
                ),
                padding: EdgeInsets.zero,
              ),
            ),

          // Overlay (action buttons, info)
          widget.overlay,
        ],
      ),
    );
  }
}
