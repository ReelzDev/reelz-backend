// ─── User Model ───────────────────────────────────────────────
class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final String country;
  final int followersCount;
  final int followingCount;
  final int totalPoints;
  final bool isVerified;
  final bool isCreator;
  final List<String> interests; // ['learn', 'earn', 'entertain']

  const UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    required this.country,
    this.followersCount = 0,
    this.followingCount = 0,
    this.totalPoints = 0,
    this.isVerified = false,
    this.isCreator = false,
    this.interests = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        username: json['username'],
        displayName: json['display_name'],
        avatarUrl: json['avatar_url'],
        bio: json['bio'],
        country: json['country'] ?? 'IQ',
        followersCount: json['followers_count'] ?? 0,
        followingCount: json['following_count'] ?? 0,
        totalPoints: json['total_points'] ?? 0,
        isVerified: json['is_verified'] ?? false,
        isCreator: json['is_creator'] ?? false,
        interests: List<String>.from(json['interests'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'bio': bio,
        'country': country,
        'followers_count': followersCount,
        'following_count': followingCount,
        'total_points': totalPoints,
        'is_verified': isVerified,
        'is_creator': isCreator,
        'interests': interests,
      };
}

// ─── Video Model ───────────────────────────────────────────────
enum VideoCategory { learn, earn, entertain, local }

enum VideoType { educational, profitable, experience }

class VideoModel {
  final String id;
  final String userId;
  final UserModel creator;
  final String videoUrl;
  final String thumbnailUrl;
  final String title;
  final String description;
  final VideoCategory category;
  final VideoType type;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int savesCount;
  final int viewsCount;
  final Duration duration;
  final bool isLiked;
  final bool isSaved;
  final String? productLink;
  final String? courseLink;
  final DateTime createdAt;
  final String country;

  const VideoModel({
    required this.id,
    required this.userId,
    required this.creator,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.savesCount = 0,
    this.viewsCount = 0,
    required this.duration,
    this.isLiked = false,
    this.isSaved = false,
    this.productLink,
    this.courseLink,
    required this.createdAt,
    required this.country,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
        id: json['id'],
        userId: json['user_id'],
        creator: UserModel.fromJson(json['creator']),
        videoUrl: json['video_url'],
        thumbnailUrl: json['thumbnail_url'],
        title: json['title'],
        description: json['description'],
        category: VideoCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => VideoCategory.entertain,
        ),
        type: VideoType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => VideoType.experience,
        ),
        likesCount: json['likes_count'] ?? 0,
        commentsCount: json['comments_count'] ?? 0,
        sharesCount: json['shares_count'] ?? 0,
        savesCount: json['saves_count'] ?? 0,
        viewsCount: json['views_count'] ?? 0,
        duration: Duration(seconds: json['duration_seconds'] ?? 0),
        isLiked: json['is_liked'] ?? false,
        isSaved: json['is_saved'] ?? false,
        productLink: json['product_link'],
        courseLink: json['course_link'],
        createdAt: DateTime.parse(json['created_at']),
        country: json['country'] ?? 'IQ',
      );
}

// ─── Comment Model ─────────────────────────────────────────────
class CommentModel {
  final String id;
  final String videoId;
  final UserModel user;
  final String text;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;
  final List<CommentModel> replies;

  const CommentModel({
    required this.id,
    required this.videoId,
    required this.user,
    required this.text,
    this.likesCount = 0,
    this.isLiked = false,
    required this.createdAt,
    this.replies = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: json['id'],
        videoId: json['video_id'],
        user: UserModel.fromJson(json['user']),
        text: json['text'],
        likesCount: json['likes_count'] ?? 0,
        isLiked: json['is_liked'] ?? false,
        createdAt: DateTime.parse(json['created_at']),
        replies: (json['replies'] as List<dynamic>?)
                ?.map((r) => CommentModel.fromJson(r))
                .toList() ??
            [],
      );
}

// ─── Points / Rewards Model ────────────────────────────────────
class PointsTransaction {
  final String id;
  final String reason; // 'watch', 'like', 'comment', 'share', 'daily_login'
  final int points;
  final DateTime createdAt;

  const PointsTransaction({
    required this.id,
    required this.reason,
    required this.points,
    required this.createdAt,
  });

  factory PointsTransaction.fromJson(Map<String, dynamic> json) =>
      PointsTransaction(
        id: json['id'],
        reason: json['reason'],
        points: json['points'],
        createdAt: DateTime.parse(json['created_at']),
      );
}
