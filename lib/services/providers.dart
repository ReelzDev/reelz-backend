import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/api_service.dart';

// ── Auth State ────────────────────────────────────────────────
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<bool> loginWithFirebase({
    required String firebaseUid,
    String? email,
    String? phone,
    String? displayName,
    String? avatarUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ApiService.loginWithFirebase(
        firebaseUid: firebaseUid,
        email: email,
        phone: phone,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );

      if (result['success']) {
        final u = result['user'];
        state = state.copyWith(
          isLoading: false,
          user: UserModel(
            id: u['id'],
            username: u['username'],
            displayName: u['display_name'],
            avatarUrl: u['avatar_url'],
            country: u['country'] ?? 'IQ',
            totalPoints: u['total_points'] ?? 0,
            isCreator: u['is_creator'] ?? false,
            interests: List<String>.from(u['interests'] ?? []),
          ),
        );
        return result['is_new'] == true;
      }
      state = state.copyWith(isLoading: false, error: 'فشل تسجيل الدخول');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'خطأ في الاتصال بالخادم');
      return false;
    }
  }

  void logout() {
    ApiService.logout();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

// ── Feed State ────────────────────────────────────────────────
class FeedState {
  final List<VideoModel> videos;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const FeedState({
    this.videos = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  FeedState copyWith({List<VideoModel>? videos, bool? isLoading, bool? hasMore, String? error}) {
    return FeedState(
      videos: videos ?? this.videos,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier() : super(const FeedState());

  int _offset = 0;
  bool _focusMode = false;
  String? _category;

  Future<void> loadFeed({bool refresh = false, bool focusMode = false, String? category}) async {
    if (state.isLoading) return;

    if (refresh) {
      _offset = 0;
      _focusMode = focusMode;
      _category = category;
      state = const FeedState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final data = await ApiService.getFeed(
        limit: 10,
        offset: _offset,
        focusMode: _focusMode,
        category: _category,
      );

      final newVideos = data.map((v) => VideoModel.fromJson(v)).toList();

      state = state.copyWith(
        videos: refresh ? newVideos : [...state.videos, ...newVideos],
        isLoading: false,
        hasMore: newVideos.length == 10,
      );

      _offset += newVideos.length;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'فشل تحميل الفيديوهات');
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await loadFeed();
  }

  void toggleLikeLocally(String videoId) {
    final videos = state.videos.map((v) {
      if (v.id == videoId) {
        final liked = !v.isLiked;
        return VideoModel(
          id: v.id,
          userId: v.userId,
          creator: v.creator,
          videoUrl: v.videoUrl,
          thumbnailUrl: v.thumbnailUrl,
          title: v.title,
          description: v.description,
          category: v.category,
          type: v.type,
          likesCount: liked ? v.likesCount + 1 : v.likesCount - 1,
          commentsCount: v.commentsCount,
          sharesCount: v.sharesCount,
          savesCount: v.savesCount,
          viewsCount: v.viewsCount,
          duration: v.duration,
          isLiked: liked,
          isSaved: v.isSaved,
          productLink: v.productLink,
          courseLink: v.courseLink,
          createdAt: v.createdAt,
          country: v.country,
        );
      }
      return v;
    }).toList();
    state = state.copyWith(videos: videos);
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>(
  (ref) => FeedNotifier(),
);

// ── Points State ──────────────────────────────────────────────
class PointsState {
  final int totalPoints;
  final int weeklyPoints;
  final List<PointsTransaction> history;
  final bool isLoading;

  const PointsState({
    this.totalPoints = 0,
    this.weeklyPoints = 0,
    this.history = const [],
    this.isLoading = false,
  });
}

class PointsNotifier extends StateNotifier<PointsState> {
  PointsNotifier() : super(const PointsState());

  Future<void> load() async {
    state = const PointsState(isLoading: true);
    try {
      final data = await ApiService.getMyPoints();
      final summary = data['summary'];
      final historyData = data['history'] as List;

      state = PointsState(
        totalPoints: summary['total_points'] ?? 0,
        weeklyPoints: int.tryParse(summary['weekly_points'].toString()) ?? 0,
        history: historyData.map((h) => PointsTransaction.fromJson(h)).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = const PointsState(isLoading: false);
    }
  }

  void addPoints(int points) {
    state = PointsState(
      totalPoints: state.totalPoints + points,
      weeklyPoints: state.weeklyPoints + points,
      history: state.history,
    );
  }
}

final pointsProvider = StateNotifierProvider<PointsNotifier, PointsState>(
  (ref) => PointsNotifier(),
);

// ── Creator Stats ─────────────────────────────────────────────
final creatorStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await ApiService.getCreatorStats();
});
